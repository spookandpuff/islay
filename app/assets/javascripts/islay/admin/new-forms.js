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
/* FORM
/* -------------------------------------------------------------------------- */
$SP.UI.Form = Backbone.View.extend(
  {
    initialize: function() {
      _.bindAll(this, 'update');

      var first = this.$el.find(':input:not(:hidden)');
      if (first) {this.prefix = first.attr('name').match(/^(.+)\[/)[1];}

      this.bindings = [];

      this.model = new Backbone.Model();
      this.model.on('change', this.update);
      this._initWidgets();
      this._initForms();
      this._initAssociations();
    },

    _initWidgets: function() {
      _.each(this.constructor.registry, function(config) {
        var fields = this.$el.find(config.selector);
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
              model: this.model
            });

            this.model.set(data.name, data.value);
            var widget = new $SP.UI.Widgets[config.widget](data);

            if (widget.broadcast) {this._proxyEvents(widget);}

            field.after(widget.render().el);
            field.remove();

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

    _initForms: function() {

    },

    _initAssociations: function() {

    },

    update: function() {
      // TODO: figure out which fields changed.
    },

    _proxyEvents: function(widget) {
      _.each(widget.broadcast, function(ev) {
        var fn = new Function("this.trigger('" + ev + "')");
        _.bind(fn, this);
        widget.on(ev, fn);
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
/* WIDGET
/* -------------------------------------------------------------------------- */
$SP.UI.Widget = Backbone.View.extend({
  className: 'field',
  tagName: 'div',

  initialize: function() {
    var bind = _.values(this.events);
    bind.unshift(this);
    bind.push('onModelUpdate');
    _.bindAll.apply(_, bind);

    if (this.model) {
      this.model.on('change:' + this.options.name, this.onModelUpdate);
    }

    this.dom = {};
  },

  onModelUpdate: function() {
    this.currentValue = this.model.get(this.options.name);
    this.updateUI(this.currentValue);
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
    this.dom.frame = $H('div.widget.' + this.widgetClass).append(this.template(this));
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
/* SELECT CONTROL
/* -------------------------------------------------------------------------- */
$SP.UI.Widgets.Select = $SP.UI.Widget.extend({
  widgetClass: 'select',
  nodes: {hook: 'input'},
  template: $SP.UI.template('<input type="hidden" name="noop"/>'),

  prepareUI: function() {
    _.bindAll(this, 'select2Change', 'select2Format');
    var opts = {
      allowClear: true,
      data: this.options.choices,
      formatResult: this.select2Format,
      initSelection: function() {}
    };
    this.dom.hook.select2(opts).on('change', this.select2Change);
  },

  select2Change: function() {
    this.updateVal(this.dom.hook.val());
  },

  select2Format: function(data) {
    var depth = this.options.choiceMap[data.id].depth;
    return '<span class="category depth-' + depth + '">' + data.text + '</span>';
  },

  updateUI: function(val) {
    this.dom.hook.select2("data", this.options.choiceMap[val]);
  }
});

$SP.UI.Form.register('.field.select', 'Select', 'Generic', function(el, input) {
  var choices = [], choiceMap = {};

  _.each(el.find('option[value!=""]'), function(opt) {
    var $opt = $(opt),
        text = $opt.text(),
        val = $opt.attr('value'),
        depth = $opt.attr('data-depth'),
        choice = {text: text, id: val || text, depth: depth || 0};

    choices.push(choice);
    choiceMap[choice.id] = choice;
  });

  return {choices: choices, choiceMap: choiceMap};
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
      '<span class="remove">&nbsp;</span>',
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
        add: this.updateSelection,
        only: 'images'
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
        choice = {text: $opt.text(), id: val || text, url: $opt.attr('data-preview')};

    if ($opt.is(':selected')) {value.push(choice.id);}
    choicesMap[choice.id] = choice;
  });

  var name = input.attr('name').match(/^.+\[(.+)\]\[/)[1];

  return {choicesMap: choicesMap, value: value, name: name};
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
