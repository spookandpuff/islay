/* -------------------------------------------------------------------------- */
/* UTILITIES
/* -------------------------------------------------------------------------- */
$SP.UI = {
  Widgets: {},
  FormBindings: {},

  template: function() {
    var template = _.toArray(arguments).join('');
    return function(context) {return Mustache.render(template, context);};
  }
};

$SP.coerce = function(type, val) {
  switch(type) {
    case 'string': return val.toString();
    case 'integer': return parseInt(val);
    case 'float': return parseFloat(val);
    case 'boolean':
      switch(val) {
        case '0':
        case 'false':
          return false;
        case '1':
        case 'true':
          return true;
      }
  }

  return val;
}

$SP.coerceArray = function(type, val) {
  return _.map(val, function(v) {return $SP.UI.coerce(v);});
};

/* -------------------------------------------------------------------------- */
/* MODEL
/* -------------------------------------------------------------------------- */
$SP.UI.FormModel = Backbone.Model.extend({
  // Temporary, until we have validations and Ajax support
  addError: function(attr, error) {
    this.trigger('invalid:' + attr, error);
  },

  incrementPosition: function() {
    var target = this.get('position') + 1;
    if (target <= this.get('maxPosition')) {this.set('position', target);}
  },

  decrementPosition: function() {
    var target = this.get('position') - 1;
    if (target > 0) {this.set('position', target);}
  }
});

/*--------------------------------------------------------------------------- */
/* ASSOCIATION
/* -------------------------------------------------------------------------- */
$SP.UI.Assocation = Backbone.View.extend({
  events: {'click .add-form': 'add'},
  pattern: /^(.+\[.+\]\[)(\d+)/,
  replace: function(m, p1, p2) {return p1 + this.index;},

  initialize: function() {
    _.bindAll(this, 'add', 'replace', 'addForm', 'move', 'destroy');

    this.listEl     = this.$el.find('ol');
    this.templateEl = this.$el.find('li:last-child');

    this.forms = [];
    _.each(this.$el.find('li:not(:last-child)'), this.addForm, this);

    var attr = this.templateEl.find(':input').attr('name'),
        index = attr.match(this.pattern)[2];

    this.index = parseInt(index);

    this.render();
  },

  addForm: function(el) {
    var form = new $SP.UI.SubForm({el: el});
    form.on('move', this.move);
    this.forms.push(form);
  },

  add: function(e) {
    var clone = this.templateEl.clone();

    _.each(clone.find(':input'), function(input) {
      var $input = $(input),
          attr   = $input.attr('name'),
          update = attr.replace(this.pattern, this.replace);

        $input.attr('name', update);
    }, this);

    if (clone.is('.collapsible')) {
      clone.removeClass('collapsed');
    }

    this.listEl.append(clone.show());
    this.addForm(clone);

    this.index += 1;
    e.preventDefault();
  },

  move: function(pos, dir) {
    var otherPos  = null,
        other     = null,
        target    = this.forms[pos];

    if (dir === 'up' && pos > 0) {
      otherPos = pos - 1,
      other    = this.forms[otherPos];

      other.$el.before(target.$el.detach());
    }
    else if (dir === 'down' && pos < this.forms.length) {
      otherPos = pos + 1,
      other    = this.forms[otherPos];

      other.$el.after(target.$el.detach());
    }

    other.updatePosition(pos);
    target.updatePosition(otherPos);
    this.resort();
  },

  destroy: function(pos) {
    // Remove form from list
  },

  resort: function() {
    this.forms.sort(function(x, y) {
      return x.options.position - y.options.position;
    });
  },

  render: function() {
    this.templateEl.detach();

    this.addEl = $H('a.button.add-form', 'Add Feature');
    this.$el.append(this.addEl);
  }
});

/* -------------------------------------------------------------------------- */
/* FORM
/* -------------------------------------------------------------------------- */
$SP.UI.Form = Backbone.View.extend(
  {
    initialize: function() {

      var first = this.$el.find(':input:not(:hidden)');
      if (first) {this.prefix = first.attr('name').match(/^(.+)\[/)[1];}

      this.bindings = [];

      this.model = new $SP.UI.FormModel();

      this._initWidgets();
      this._initForms();
    },

    _initWidgets: function() {
      _.each(this.constructor.registry, function(config) {
        var fields = this.$el.find(this._coerceSelector(config.selector));

        if (fields.length > 0) {
          _.each(fields, function(f) {
            var field = $(f),
                input = field.find(':input');

            var data = _.defaults(config.initializer(field, input), {
              label: field.find('label:first').text(),
              value: input.val(),
              type: 'string',
              required: input.attr('required') ? true : false,
              name: input.attr('name').match(/^.+\[(.+)\]/)[1],
              model: this.model,
              errored: field.is('.errored'),
              error: field.find('.error').text(),
              inline: field.is('.count-inline'),
              firstInline: field.is('.count-first-inline')
            });

            this.model.set(data.name, data.value);
            var widget = new $SP.UI.Widgets[config.widget](data);

            field.after(widget.render().el);
            field.remove();

            // Temporary error propagation
            if (data.errored) {this.model.addError(data.name, data.error);}

            this.bindings.push(new $SP.UI.FormBindings[config.binder](
              this.$el,
              this.model,
              this.prefix,
              data.name,
              data.type
            ));
          }, this);
        }
      }, this);
    },

    _coerceSelector: function(selector) {
      return _.map(selector.split(','), function(s) {
        return $.trim(s) + ':not(.association .field)';
      }).join(', ');
    },

    _initForms: function() {
      var assocs = this.$el.find('.association');
      this.associations = _.map(assocs, function(a) {
        return new $SP.UI.Assocation({el: a});
      }, this);
    }
  },

  {
    registry: [],

    register: function(selector, widget, binder, initializer) {
      this.registry.push({
        selector: selector,
        widget: widget,
        binder: binder,
        initializer: initializer
      });
    }
  }
);

/* -------------------------------------------------------------------------- */
/* SUB-FORM
/* -------------------------------------------------------------------------- */
$SP.UI.SubForm = $SP.UI.Form.extend({
  initialize: function() {
    $SP.UI.Form.prototype.initialize.apply(this);

    _.bindAll(this, 'reposition', 'destroy');

    this.model.set('maxPosition', this.options.maxPosition);

    this.model.on('change:position', this.reposition);
    this.model.on('change:_destroy', this.destroy);
  },

  reposition: function() {
    if (this.pause) {
      this.pause = false;
    }
    else {
      var position = this.model.get('position');
      if (this.model.previous('position') > position) {
        this.trigger('move', 'up');
      }
      else {
        this.trigger('move', 'down');
      }
    }
  },

  position: function() {
    return this.model.get('position');
  },

  setPosition: function(pos) {
    this.pause = true;
    this.model.set('position', pos);
  },

  destroy: function() {
    this.$el.hide();
  },

  _coerceSelector: function(selector) {
    return selector;
  },

  _initForms: function() {
    // Can't have forms nested in forms nested in forms.
  }
});

/* -------------------------------------------------------------------------- */
/* WIDGET
/* -------------------------------------------------------------------------- */
$SP.UI.Widget = Backbone.View.extend({
  className: 'field',
  tagName: 'div',

  initialize: function() {
    var bind = _.values(this.events);
    bind.unshift(this);
    bind.push('onModelUpdate', 'onModelInvalid');
    _.bindAll.apply(_, bind);

    if (this.model) {
      this.model.on('change:' + this.options.name, this.onModelUpdate);
      this.model.on('invalid:' + this.options.name, this.onModelInvalid);
    }

    this.dom = {};
  },

  onModelUpdate: function() {
    this.currentValue = this.model.get(this.options.name);
    this.updateUI(this.currentValue);
  },

  onModelInvalid: function(msg) {
    if (!this.dom.error) {
      this.dom.error = $H('span.error');
      this.dom.frame.after(this.dom.error);
    }
    this.dom.error.text(msg);
    this.dom.error.show();
  },

  updateVal: function(val) {
    if (this.model) {this.model.set(this.options.name, val);}
  },

  updateUI: function() {
    throw 'Not implemented';
  },

  coerce: function(val) {
    return $SP.coerce(this.options.type, val);
  },

  render: function() {
    this.$el.addClass(this.widgetClass).addClass('widget');
    this.dom.frame = $H('div.widget-frame').append(this.template(this));

    if (this.options.firstInline) {
      this.$el.addClass('count-first-inline');
    }
    else if (this.options.inline) {
      this.$el.addClass('count-inline');
    }

    this._findNodes();
    this._findCollectionNodes();
    this.dom.label = $H('label', this.options.label);
    this.$el.append(this.dom.label, this.dom.frame);

    if (this.prepareUI) {this.prepareUI();}

    this.updateUI(this.model.get(this.options.name));

    return this;
  },

  _findNodes: function() {
    if (this.nodes) {
      _.each(this.nodes, function(selector, name) {
        this.dom[name] = this.dom.frame.find(selector);
      }, this);
    }
  },

  _findCollectionNodes: function() {
    if (this.nodeCollections) {
      _.each(this.nodeCollections, function(selector, name) {
        var nodes = this.dom.frame.find(selector);
        this.dom[name] = _.reduce(nodes, function(acc, node) {
          var $node = $(node),
              nodeVal = this.coerce($node.attr('data-value')),
              nodeName = $node.attr('data-name');

          acc[nodeName || nodeVal] = $node;
          return acc;
        }, {}, this);
      }, this);
    }
  }
});

/* -------------------------------------------------------------------------- */
/* CHECKBOXES CONTROL
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.Checkboxes = $SP.UI.Widget.extend({
  widgetClass: 'checkboxes',
  nodeCollections: {choices: 'li'},
  events: {'click li': 'click'},
  template: $SP.UI.template(
    '<ul>',
      '{{#options.choices}}',
        '<li class="button" data-value="{{value}}"><span>{{label}}</span></li>',
      '{{/options.choices}}',
    '</ul>'
  ),

  click: function(e) {
    var target = $(e.target);
    if (target.is('span')) {target = target.parent('li');}
    var val = target.attr('data-value'), vals;
    if (this.vals.indexOf(val) > -1) {
      vals = _.without(this.vals, val);
    }
    else {
      vals = this.vals.concat(val);
    }

    this.updateVal(vals);
  },

  updateUI: function(vals) {
    this.vals = vals;
    _.each(this.dom.choices, function(n) {n.removeClass('selected');});
    _.each(vals, function(val) {this.dom.choices[val].addClass('selected');}, this);
  }
});

$SP.UI.Form.register('.field.check_boxes', 'Checkboxes', 'Array', function(el, input) {
  var choices = [], value = [];
  _.each(el.find('input[type=checkbox]'), function(opt) {
    var $opt = $(opt), label = $opt.parent('label'), val = $opt.attr('value');
    choices.push({label: label.text(), value: val});
    if ($opt.is(':checked')) {value.push(val);}
  });

  var name = input.attr('name').match(/^.+\[(.+)\]\[/)[1];

  return {choices: choices, value: value, name: name};
});

/* -------------------------------------------------------------------------- */
/* INPUT FIELD CONTROL (string, numeric, etc.)
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.Input = $SP.UI.Widget.extend({
  widgetClass: 'string',
  nodes: {input: 'input'},
  events: {'keyup input': 'keyup'},
  template: $SP.UI.template(
    '<input class="{{options.classNames}}" size="{{options.size}}" type="{{options.inputType}}" value="{{options.value}}" />'
  ),

  keyup: function() {
    this.pauseUiUpdate = true;
    this.updateVal(this.dom.input.val());
  },

  updateUI: function(val) {
    if (this.pauseUiUpdate) {
      this.pauseUiUpdate = false
    }
    else {
      this.dom.input.val(val);
    }
  }
});

$SP.UI.Form.register('.field.string, .field.float, .field.integer', 'Input', 'Generic', function(el, input) {
  return {
    size: input.attr('size'),
    inputType: input.attr('type'),
    classNames: input.attr('class')
  };
});

/* -------------------------------------------------------------------------- */
/* BOOLEAN TOGGLE CONTROL
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.Boolean = $SP.UI.Widget.extend({
  widgetClass: 'boolean',
  nodes: {on: 'li.on', off: 'li.off'},
  events: {'click li.on': 'clickOn', 'click li.off': 'clickOff'},
  template: $SP.UI.template(
    '<ul>',
      '<li class="off button"><span>Off</span></li>',
      '<li class="on button"><span>On</span></li>',
    '</ul>'
  ),

  clickOff: function() {
    this.updateVal(false);
  },

  clickOn: function() {
    this.updateVal(true);
  },

  updateUI: function(val) {
    if (this.current) {this.current.removeClass('selected');}
    var node = val === true? 'on' : 'off';
    this.current = this.dom[node].addClass('selected');
  }
});

$SP.UI.Form.register('.field.boolean', 'Boolean', 'Boolean', function(el, input) {
  return {type: 'boolean', value: $SP.coerce('boolean', input.is(':checked'))};
});

/* -------------------------------------------------------------------------- */
/* SEGMENTED CONTROL
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.Segmented = $SP.UI.Widget.extend({
  widgetClass: 'segmented',
  nodeCollections: {choices: 'li'},
  events: {'click li': 'clickChoice'},
  template: $SP.UI.template(
    '<ul>',
      '{{#options.choices}}',
        '<li class="button" data-value="{{value}}"><span>{{label}}</span></li>',
      '{{/options.choices}}',
    '</ul>'
  ),

  clickChoice: function(e) {
    var target = $(e.target);
    if (target.is('span')) {target = target.parent('li');}
    this.updateVal(this.coerce(target.attr('data-value')));
  },

  updateUI: function(val) {
    if (this.current) {this.current.removeClass('selected');}
    this.current = this.dom.choices[val].addClass('selected');
  }
});

$SP.UI.Form.register('.field.radio_buttons', 'Segmented', 'Generic', function(el) {
  var choices = [], value = null;
  _.each(el.find('input[type=radio]'), function(opt) {
    var $opt = $(opt),
        label = $opt.parent('label'),
        choice = {label: label.text(), value: $opt.val()};

    choices.push(choice);
    if ($opt.is(':checked')) {value = choice.value;}
  });

  return {choices: choices, value: value};
});

/* -------------------------------------------------------------------------- */
/* SELECT-BASE CONTROL
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.SelectBase = $SP.UI.Widget.extend({
  widgetClass: 'select',
  nodes: {hook: 'input'},
  template: $SP.UI.template('<input type="hidden" name="noop"/>'),
  select2opts: {},

  prepareUI: function() {
    _.bindAll(this, 'select2Change', 'select2Format');
    var opts = _.extend({
      allowClear: this.options.allowClear,
      placeholder: 'None selected',
      data: this.options.choices,
      formatResult: this.select2Format,
      initSelection: function() {}
    }, this.select2opts);

    this.dom.hook.select2(opts).on('change', this.select2Change);
  },

  select2Change: function() {
    this.updateVal(this.dom.hook.select2('val'));
  },

  select2Format: function(data) {
    return data.text;
  },

  updateUI: function(val) {
    this.dom.hook.select2("data", this.options.choiceMap[val]);
  }
});

/* -------------------------------------------------------------------------- */
/* SELECT CONTROL
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.Select = $SP.UI.Widgets.SelectBase.extend({
  choiceTemplate: $SP.UI.template(
    '<span class="entry depth-{{depth}} disabled-{{disabled}}">',
      '<span>{{text}}</span>',
    '</span>'
  ),

  select2Format: function(data) {
    return this.choiceTemplate(this.options.choiceMap[data.id]);
  },
});

$SP.UI.Form.register('.field.select, .field.tree_select', 'Select', 'Generic', function(el, input) {
  var choices = [], choiceMap = {};

  _.each(el.find('option[value!=""]'), function(opt) {
    var $opt = $(opt),
        text = $.trim($opt.text()),
        val = $opt.attr('value'),
        depth = $opt.attr('data-depth'),
        choice = {text: text, id: val || text, depth: depth || 0, disabled: $opt.is(':disabled')};

    choices.push(choice);
    choiceMap[choice.id] = choice;
  });

  return {
    choices: choices,
    choiceMap: choiceMap,
    allowClear: input.find('option[value!=""]').length > 0
  };
});

/* -------------------------------------------------------------------------- */
/* MULTI-SELECT CONTROL
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.MultiSelect = $SP.UI.Widgets.SelectBase.extend({
  widgetClass: 'multi-select',
  select2opts: {multiple: true},

  updateUI: function(val) {
    var choices = _.map(val, function(v) {return this.options.choiceMap[v];}, this);
    this.dom.hook.select2("data", choices);
  }
});

$SP.UI.Form.register('.field.multi_select', 'MultiSelect', 'Array', function(el, input) {
  var choiceMap = {}, choices = [], value = [];

  _.each(input.find('option'), function(opt) {
    var $opt = $(opt), choice = {text: $opt.text(), id: $opt.attr('value')};
    choiceMap[choice.id] = choice;
    choices.push(choice);
    if ($opt.is(':selected')) {value.push(choice.id);}
  });

  var name = input.attr('name').match(/^.+\[(.+)\]\[/)[1];

  return {
    choiceMap: choiceMap,
    choices: choices,
    name: name,
    value: value
  };
});

/* -------------------------------------------------------------------------- */
/* SINGLE-ASSET CONTROL
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.SingleAsset = $SP.UI.Widget.extend({
  widgetClass: 'single_asset',
  events: {'click img, .placeholder': 'modify', 'click .remove': 'remove'},
  nodes: {choice: '.choice'},
  template: $SP.UI.template(
    '<div class="choice"><span class="placeholder">Choose an Image</span></div>'
  ),
  entryTemplate: $SP.UI.template(
    '<img src="{{url}}" alt="{{text}}" /><span class="remove"></span>'
  ),
  placeholderTemplate: $SP.UI.template(
    '<span class="placeholder">Choose an Image</span>'
  ),

  remove: function() {
    this.dom.choice.html(this.placeholderTemplate());
    this.updateVal(null);
  },

  modify: function(e) {
    if (this.dialog) {
      this.dialog.show();
    }
    else {
      _.bindAll(this, 'update');
      this.dialog = new Islay.Dialogs.AssetBrowser({add: this.update, only: 'images'});
    }
  },

  update: function(selections) {
    if (selections.length > 0) {this.updateVal(selections[0].id);}
  },

  updateUI: function(val) {
    if (val) {
      var vals = this.options.choicesMap[val];
      this.dom.choice.html(this.entryTemplate(vals));
    }
  }
});

$SP.UI.Form.register('.field.single_asset', 'SingleAsset', 'Generic', function(el, input) {
  var choicesMap = {}, value;

  _.each(input.find('option'), function(opt) {
    var $opt = $(opt),
        val = $opt.attr('value'),
        text = $opt.text(),
        choice = {text: text, id: val || text, url: $opt.attr('data-preview')};

    if ($opt.is(':selected')) {value = choice.id;}
    choicesMap[choice.id] = choice;
  });

  return {choicesMap: choicesMap, value: value};
});

/* -------------------------------------------------------------------------- */
/* MULTI-ASSET CONTROL
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.MultiAsset = $SP.UI.Widget.extend({
  widgetClass: 'multi_asset',
  events: {'click .choice .remove': 'removeAsset', 'click .add': 'clickAdd'},
  nodes: {add: '.add'},
  nodeCollections: {choices: 'li.choice'},
  template: $SP.UI.template(
    '<ul>',
      '<li class="add"><span>Add Asset</span></li>',
    '</ul>'
  ),
  entryTemplate: $SP.UI.template(
    '<li class="choice" data-value="{{id}}">',
      '<img src="{{url}}" alt="{{text}}" />',
      '<span class="remove"></span>',
    '</li>'
  ),

  removeAsset: function(e) {
    var target = $(e.target),
        id = (target.is('span') ? target.parent('li.choice') : target).attr('data-value');
        val = _.without(this.value, id);

    this.updateVal(val);
  },

  clickAdd: function() {
    if (this.dialog) {
      this.dialog.show();
    }
    else {
      _.bindAll(this, 'updateSelection');
      this.dialog = new Islay.Dialogs.AssetBrowser({
        add: this.updateSelection
      });
    }
  },

  updateSelection: function(selections) {
    var val = this.value.concat(_.chain(selections).pluck('id').invoke('toString').value());
    this.updateVal(_.uniq(val));
  },

  updateUI: function(val) {
    if (this.value) {
      this.removeNodes(_.difference(this.value, val));
      this.addNodes(_.difference(val, this.value));
    }
    else {
      this.addNodes(val);
    }
    this.value = val;
  },

  addNodes: function(ids) {
    _.each(ids, function(id) {
      var choice = this.options.choicesMap[id],
          li = $(this.entryTemplate(choice)).css('opacity', 0);

      this.dom.add.before(li);
      li.animate({opacity: 1}, 350);
      this.dom.choices[id] = li;
    }, this);
  },

  removeNodes: function(ids) {
    _.each(ids, function(id) {
      var opts = {opacity: 0, width: '0', marginRight: 0};
      this.dom.choices[id].animate(opts, 300, 'linear', function() {
        $(this).remove();
      });
      delete this.dom.choices[id];
    }, this);
  }
});

$SP.UI.Form.register('.field.multi_asset', 'MultiAsset', 'Array', function(el, input) {
  var choicesMap = {}, value = [];

  _.each(input.find('option'), function(opt) {
    var $opt = $(opt),
        val = $opt.attr('value'),
        text = $opt.text(),
        choice = {text: text, id: val || text, url: $opt.attr('data-preview')};

    if ($opt.is(':selected')) {value.push(choice.id);}
    choicesMap[choice.id] = choice;
  });

  var name = input.attr('name').match(/^.+\[(.+)\]\[/)[1];

  return {choicesMap: choicesMap, value: value, name: name};
});

/* -------------------------------------------------------------------------- */
/* POSITION CONTROL
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.Position = $SP.UI.Widget.extend({
  widgetClass: 'position',
  events: {'click li': 'click'},
  template: $SP.UI.template(
    '<ul>',
      '<li class="up"><span></span></li>',
      '<li class="down"><span></span></li>',
    '</ul>'
  ),

  click: function(e) {
    var target = $(e.target);
    if (target.is('span')) {target = target.parent('li');}
    if (target.is('.up')) {
      this.model.decrementPosition();
    }
    else if (target.is('.down')) {
      this.model.incrementPosition();
    }
  },

  // A noop
  updateUI: function() {}
});

$SP.UI.Form.register('.field.position', 'Position', 'Generic', function(el, input) {
  return {type: 'integer', value: parseInt(input.val())};
});

/* -------------------------------------------------------------------------- */
/* DESTROY CONTROL
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.Destroy = $SP.UI.Widget.extend({
  widgetClass: 'delete',
  events: {'click': 'click'},
  template: $SP.UI.template(
    '<div><span></span></div>'
  ),

  click: function() {
    this.model.set(this.options.name, true);
  },

  // A noop
  updateUI: function() {}
});

$SP.UI.Form.register('.field.destroy', 'Destroy', 'Boolean', function(el, input) {
  return {type: 'boolean', value: false};
});

/* -------------------------------------------------------------------------- */
/* FORM BINDING - GENERIC
/* -------------------------------------------------------------------------- */
$SP.UI.FormBindings.Generic = function(form, model, prefix, name, type) {
  _.bindAll(this, 'update');
  this.form = form;
  this.model = model;
  this.name = name;
  this.type = type;
  this.prefix = prefix;

  this.model.on('change:' + this.name, this.update);

  this.build(this.inputName());
  this.update();
};

$SP.UI.FormBindings.Generic.prototype = {
  update: function() {
    var val = this.model.get(this.name);
    this.updateInput(val);
  },

  build: function(name) {
    this.input = $H('input[type=hidden]', {name: name});
    this.form.append(this.input);
  },

  inputName: function() {
    return this.prefix + '[' + this.name + ']';
  },

  updateInput: function(val) {
    this.input.val(val);
  }
};

// Piggy-back on backbone's extend for easy inheritance.
$SP.UI.FormBindings.Generic.extend = Backbone.Model.extend;

/* -------------------------------------------------------------------------- */
/* FORM BINDING - SPECIFIC IMPLEMENTATIONS
/* -------------------------------------------------------------------------- */
$SP.UI.FormBindings.Boolean = $SP.UI.FormBindings.Generic.extend({
  updateInput: function(val) {
    this.input.val(val ? 1 : 0);
  }
});

$SP.UI.FormBindings.Array = $SP.UI.FormBindings.Generic.extend({
  build: function() {
    this.inputs = [];
  },

  inputName: function() {
    return this.prefix + '[' + this.name + '][]';
  },

  updateInput: function(vals) {
    _.invoke(this.inputs, 'remove');
    this.inputs = _.map(vals, function(val) {
      var input = $H('input', {type: 'hidden', value: val, name: this.inputName()});
      this.form.append(input);
      return input;
    }, this);
  }
});
