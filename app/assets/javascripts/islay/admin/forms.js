// View instantiates
// Stubs model
// Iterates over inputs
// Grabs values
// Generates widgets
// Binds change events from widgets to view
// View updates model on change
// Before view submits.
var Islay = window.Islay || {};

// Understands required
Islay.FormModel = Backbone.Model.extend({

});

/* -------------------------------------------------------------------------- */
/* ASSOCIATION
/* -------------------------------------------------------------------------- */
Islay.Assocation = Backbone.View.extend({
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
    var form = new Islay.Form({el: el, position: this.forms.length});
    form.on('destroy', this.destroy);
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
/* FORM TABS
/* -------------------------------------------------------------------------- */
Islay.FormTabs = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'click');

    this.tabs = {};

    var list = $H('ul.tabset'),
        hash = window.location.hash.split('#').pop();

    _.each(this.options.tabs, function(t, i) {
      var tab = $(t), name = 'tab-' + i;
      var node = $H('li', {'data-index': name}, tab.find('> legend').remove().text());
      this.tabs[name] = tab;

      if (hash !== '') {
        if (hash === name) {
          this.currentTab = node;
          node.addClass('selected');
        }
        else {
          tab.hide();
        }
      }
      else {
        if (!this.currentTab) {
          this.currentTab = node;
          node.addClass('selected');
        }
        else {
          tab.hide();
        }
      }

      list.append(node);
    }, this);

    list.click(this.click);
    this.options.tabs.first().before(list);
  },

  click: function(e) {
    var target = $(e.target);
    if (target.is('li')) {
      if (this.currentTab) {
        this.tabs[this.currentTab.attr('data-index')].hide();
        this.currentTab.removeClass('selected');
      }
      this.currentTab = target;
      this.currentTab.addClass('selected');
      var name = this.currentTab.attr('data-index');
      this.tabs[name].show();
      window.location.hash = name;
    }
  }
});

/* -------------------------------------------------------------------------- */
/* FORMS
/* -------------------------------------------------------------------------- */
Islay.Form = Backbone.View.extend({
  events: {submit: 'submit'},

  initialize: function() {
    _.bindAll(this, 'submit', 'destroy', 'move');
    this.factories = [];
    this.forms = [];

    this.model = new Islay.FormModel();

    // Figure out the name based on the prefix of the first input
    var name = this.$el.find(":input[name*='[']").attr('name')
    if (name) {
      this.name = name.match(/^(.+)\[.+\]$/)[1];
    }

    if (this.$el.is('.associated')) {
      var inputs = this.$el.find('.field');
    }
    else {
      var inputs = this.$el.find('.field:not(.associated .field)');
      var tabs = this.$el.find('.tab');
      if (tabs.length > 0) {this.tabSet = new Islay.FormTabs({tabs: tabs});}
      this.initializeAssocations();
    }

    this.widgets = _.reduce(inputs, this.initializeWidgets, {}, this);
  },

  initializeAssocations: function() {
    var assocs = this.$el.find('.association');
    this.associations = _.map(assocs, function(a) {
      return new Islay.Assocation({el: a});
    }, this);
  },

  initializeWidgets: function(obj, el) {
    var $el = $(el),
        widget = null,
        subscribe = null;

    var match = $el.attr('class').match(/^field ([\w\d\-_]+)/);

    if (match) {
      switch(match[1]) {
        case 'select':
          widget = 'Select';
        break;
        case 'boolean':
          if ($el.find(':input[name*=_destroy]').length) {
            widget = 'Destroy';
            subscribe = 'destroy';
          }
          else {
            widget = 'Boolean';
          }
        break;
        case 'radio_buttons':
          widget = 'Segmented';
        break;
        case 'check_boxes':
          widget = 'Checkboxes';
        break;
        case 'multi-images':
          widget = 'MultipleAssets';
        break;
        case 'single_asset':
          widget = 'SingleAssetPicker';
        break;
        case 'integer':
          if ($el.find(':input[name*=position]').length) {
            widget = 'Position';
            subscribe = 'move';
          }
        break;
      }

      if (widget) {
        var instance = new Islay.Widgets[widget]({el: el});
        if (subscribe) {instance.on(subscribe, this[subscribe]);}
        instance.render();

        // TODO: Bind widgets to model
      }
    }

    return obj;
  },

  destroy: function() {
    var destroy = $H('input', {type: 'hidden', name: this.name + '[_destroy]', value: 1, 'class': 'destroy-marker'});

    var undo = $H('a', {'class': 'destroy-undo'}, 'Undo'),
        destroyed = this;

    undo.click(function(){

      destroyed.$el
        .removeClass('destroyed')
        .find('.destroyed-message').remove()

      destroyed.$el
        .find('.destroy-marker').remove();
    });

    this.$el
      .addClass('destroyed')
      .append('<div class="destroyed-message">This item has been marked for deletion - save to confirm. </div>')
      .append(destroy);

    this.$el.find('.destroyed-message').append(undo);

    this.trigger('destroy', this.options.position);
  },

  move: function(dir) {
    this.trigger('move', this.options.position, dir);
  },

  updatePosition: function(pos) {
    if (!this.positionEl) {this.positionEl = this.$el.find(':input[name*=position]');}
    this.positionEl.attr('value', pos);
    this.options.position = pos;
  },

  submit: function() {

  }
}, {
  registry: [],

  register: function(selector, constructor, extractor) {
    this.registry.push({
      selector: selector,
      constructor: constructor,
      extractor: extractor
    });
  }
});

/* -------------------------------------------------------------------------- */
/* WIDGET BASE
/* -------------------------------------------------------------------------- */
Islay.Widgets = Islay.Widgets || {};

Islay.Widgets.Base = Backbone.View.extend({
  events: {'click': '_click', keyup: 'keyup'},
  widgetClass: 'default',
  inputsSelector: ':input[type!=hidden]',
  removeSelector: ':input[class!=islay]',

  initialize: function() {
    this.fields = {};
    this.widget = $H('div.widget.' + this.widgetClass);
    this.inputs = this.$el.find(this.inputsSelector);
    this.$el.append(this.widget);
    this.initialValue = this.getInitialValue();
    this.initFields();
    this.$el.find(this.removeSelector + ':not(.widget *)').remove();
  },

  update: function(value, field) {
    if (field) {
      this.trigger('update', field, value);
      this.fields[field].val(value);
    }
    else {
      this.trigger('update', this.fieldName, value);
      this.fields[this.fieldName].val(value);
    }
  },

  addField: function(field, value) {
    var node = $H('input.islay', {type: 'hidden', value: value, name: field});
    this.fields[field] = node;
    this.$el.append(node);
    return node;
  },

  // Overridable
  initFields: function() {
    var field = this.$el.find(':input[type!=hidden]'),
        name = field.attr('name');

    this.addField(name, this.initialValue);
    this.fieldName = name;
  },

  // Overridable
  getInitialValue: function() {
    if (this.inputs.filter(':radio, :checkbox').length) {
      return this.inputs.filter(':checked').val(); //If the inputs have checkboxes or radios, grab the checked value
    } else {
      return this.inputs.val();  //Otherwise, use the first value
    }
  },

  currentValue: function(field) {
    if (field) {
      return this.fields[field].val();
    }
    else {
      return this.fields[this.fieldName].val();
    }
  },

  render: function() {
    throw "Unimplemented";
  },

  click: function() {
    throw "Unimplemented";
  },

  keyup: function() {
    throw "Unimplemented";
  },

  eachLabelAndInput: function(fn) {
    _.each(this.inputs, function(input) {
      var i = $(input);
      fn.apply(this, [i, i.attr('name'), i.attr('value'), i.parent('label').text()]);
    }, this);
  },

  _click: function(e) {
    var target = $(e.target);
    this.click(e, target);
  }
});

/* -------------------------------------------------------------------------- */
/* SIMPLE SELECT
/* -------------------------------------------------------------------------- */
Islay.Widgets.Select = Islay.Widgets.Base.extend({
  widgetClass: 'select',
  removeSelector: 'select',

  open: function() {
    this.isOpen = true;
    this.widget.addClass('open');
    this.list.show();
  },

  close: function() {
    this.isOpen = false;
    this.widget.removeClass('open');
    this.list.hide();
  },

  click: function(e, target) {
    if (target.is('.frame, .button, .display, span')) {
      if (this.isOpen) {
        this.close();
      }
      else {
        this.open();
      }
    }
    else if (target.is('li')) {
      this.display.text(target.text());
      this.update(target.attr('data-value'));
      this.close();
    }
  },

  render: function() {
    this.display = $H('div.display');
    this.button = $H('div.button', $H('span', '▾'));
    var frame = $H('div.frame', [this.display, this.button]);
    this.list = $H('ul.list');

    this.widget.append(frame, this.list);

    var currentValue = this.currentValue();
    _.each(this.inputs.find('option'), function(opt) {
      opt = $(opt);
      var value = opt.attr('value'),
          text  = opt.text();

      if (value == currentValue) {this.display.text(text);}
      this.list.append($H('li', {'data-value': value}, text));
    }, this);

    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* BOOLEAN SWITCH
/* -------------------------------------------------------------------------- */
Islay.Widgets.Boolean = Islay.Widgets.Base.extend({
  widgetClass: 'boolean',

  click: function(e, target) {
    if (target.is('li, span')) {
      if (this.currentValue() == 1) {
        this.update(0);
        this.optionOn.removeClass('selected');
        this.optionOff.addClass('selected');
      }
      else {
        this.update(1);
        this.optionOff.removeClass('selected');
        this.optionOn.addClass('selected');
      }
    }
  },

  getInitialValue: function() {
    return this.$el.find(':input[type!=hidden]').is(':checked') ? 1 : 0;
  },

  render: function() {
    this.optionOff = $H('li.button.optionOff', $H('span', '✕'));
    this.optionOn = $H('li.button.optionOn', $H('span', '✓'));
    var frame = $H('ul.frame', [this.optionOff, this.optionOn]);
    this.widget.append(frame);

    if (this.initialValue == 1) {
      this.optionOn.addClass('selected');
    }
    else {
      this.optionOff.addClass('selected');
    }

    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* SIMPLE WIDGET BASE
/* -------------------------------------------------------------------------- */
Islay.Widgets.SimpleBase = Backbone.View.extend({
  events: {click: '_click'},

  initialize: function() {
    _.bindAll(this, 'click');
  },

  _click: function(e) {
    var target = $(e.target);
    this.click(e, target);
    e.preventDefault();
  },
})

/* -------------------------------------------------------------------------- */
/* DESTROY/REMOVE
/* -------------------------------------------------------------------------- */
Islay.Widgets.Destroy = Islay.Widgets.SimpleBase.extend({
  click: function() {
    this.trigger('destroy');
  },

  render: function() {
    this.$el.children().remove();
    this.$el.addClass('delete').addClass('widget').append($H('div', $H('span', '')));

    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* POSITION
/* -------------------------------------------------------------------------- */
Islay.Widgets.Position = Islay.Widgets.SimpleBase.extend({
  click: function(e, target) {
    if (target.is('span')) {
      this.fireEvent(target.parent('div'));
    }
    else {
      this.fireEvent(target);
    }
  },

  fireEvent: function(target) {
    if (target.is('.up')) {
      this.trigger('move', 'up');
    }
    else if (target.is('.down')) {
      this.trigger('move', 'down');
    }
  },

  render: function() {
    this.$el.find('label').remove();
    this.$el.find('input').hide();
    this.$el.addClass('position').addClass('widget');
    this.$el.append(
      $H('div.up', $H('span', '')),
      $H('div.down', $H('span', ''))
    );

    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* SEGMENTED CONTROL
/* -------------------------------------------------------------------------- */
Islay.Widgets.Segmented = Islay.Widgets.Base.extend({
  widgetClass: 'segmented',
  removeSelector: 'label.radio',

  click: function(e, target) {
    if (target.is('li')) {
      this.highlight(target);
    }
    else if (target.is('span')) {
      this.highlight(target.parent('li'));
    }
  },

  highlight: function(el) {
    this.update(el.attr('data-value'));
    if (this.currentNode) {this.currentNode.removeClass('selected');}
    this.currentNode = el;
    this.currentNode.addClass('selected');
  },

  render: function() {
    var frame = $H('ul.frame');
    var currentValue = this.inputs.filter(':checked').val();
    _.each(this.inputs, function(input) {
      var input = $(input),
          value = input.val();

      var node = $H('li.button', {'data-value': value}, $H('span', input.parent().text()));
      if (value == currentValue) {
        node.addClass('selected');
        this.currentNode = node;
      }
      frame.append(node);
    }, this);

    this.widget.append(frame);

    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* CHECKBOXES
/* -------------------------------------------------------------------------- */
Islay.Widgets.Checkboxes = Islay.Widgets.Base.extend({
  widgetClass: 'checkboxes',
  removeSelector: 'label.checkbox',

  click: function(e, target) {
    if (target.is('li')) {
      this.highlight(target);
    }
    else if (target.is('span')) {
      this.highlight(target.parent('li'));
    }
  },

  initFields: function() {
    _.each(this.inputs, function(i) {
      var input = $(i);
      this.addField(input.attr('name'), input.val());
    }, this);
  },

  highlight: function(el) {
    var input = this.$el.find('[value=' + el.attr('data-value') + ']');

    if (el.hasClass('selected')) {
      input.attr('disabled', 'disabled');
      el.removeClass('selected');
    }
    else {
      input.attr('disabled', null);
      el.addClass('selected');
    }
  },

  render: function() {
    var frame = $H('ul.frame');

    this.eachLabelAndInput(function(input, name, value, text) {
      var node = $H('li.button', {'data-value': value, name: name}, $H('span', text));

      if (input.attr('checked')) {
        node.addClass('selected');
      }
      else {
        // A dirty, dirty hack. This will have to be fixed at some point.
        var hiddenName = '[type=hidden][value=' + input.attr('value') + ']';
        this.$el.find(hiddenName).attr('disabled', 'disabled');
      }

      frame.append(node);
    });

    this.widget.append(frame);

    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* MULTI-SELECT
/* -------------------------------------------------------------------------- */
Islay.Widgets.MultiSelect = Islay.Widgets.Base.extend({
  widgetClass: 'multi-select',

  click: function() {

  },

  render: function() {

    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* SINGLE ASSET PICKER
/* -------------------------------------------------------------------------- */
Islay.Widgets.SingleAssetPicker = Islay.Widgets.Base.extend({
  widgetClass: 'single-asset',

  click: function() {
    if (this.dialog) {
      this.dialog.show();
    }
    else {
      _.bindAll(this, 'updateSelection');
      this.dialog = new Islay.Dialogs.AssetBrowser({add: this.updateSelection, only: 'images'});
    }
  },

  updateSelection: function(selections) {
    var selection = selections[0];
    this.updateImage(selection.get('url'));
    this.fields[this.fieldName].val(selection.id);
  },

  updateImage: function(url) {
    if (!this.image) {
      this.image = $H('img');
      this.widget.append($H('div.frame', this.image));
    }
    
    this.image.attr('src', url);
  },

  render: function() {
    var val = this.currentValue();
    if (!_.isEmpty(val)) {
      var opt = this.inputs.find('option[value=' + val + ']');
      this.updateImage(opt.attr('data-preview'));
    }
    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* MULTI-ASSET SELECTOR
/* Actually delegates selection to the asset browser dialog.
/* -------------------------------------------------------------------------- */
Islay.Widgets.MultipleAssets = Islay.Widgets.Base.extend({
  tagName: 'ul',
  widgetClass: 'multi-assets',
  removeSelector: 'ul',

  initFields: function() {
    this.fieldName = this.$el.find('ul').attr('data-name');
    this.ulEl = $H('ul');
    this.widget.append(this.ulEl);

    _.each(this.$el.find('li:not(.add)'), function(li) {
      var $li = $(li);

      var field   = $li.find(':input[type!=hidden]'),
          name    = field.attr('name')
          title   = $li.find('label').text()
          url     = $li.find('img').attr('src');

      this.addField(name, field.val(), title, url);
    }, this);

  },

  addField: function(name, val, title, url) {
    var node = $H('li.entry', [
      $H('input.islay', {type: 'hidden', value: val, name: name}),
      $H('div.frame', $H('img', {src: url, alt: title})),
      $H('div.remove', '', {alt: 'Remove this asset'})
    ]);

    this.fields[val] = node;
    if (this.addEl) {
      this.addEl.before(node);
    }
    else {
      this.ulEl.append(node);
    }

    return node;
  },

  getInitialValue: function() {
    return _.map(this.$el.find('input'), function(i) {return $(i).val();});
  },

  click: function(e) {
    var target = $(e.target);

    if (target.is('.remove')) {
      var parent = target.closest('.entry');
      delete this.fields[parent.find('input').val()];
      parent.remove();
    }
    else if (target.is('.add')) {
      this.openDialog();
    }

    e.preventDefault();
  },

  openDialog: function() {
    if (this.dialog) {
      this.dialog.show();
    }
    else {
      _.bindAll(this, 'updateSelection');
      this.dialog = new Islay.Dialogs.AssetBrowser({add: this.updateSelection});
    }
  },

  updateSelection: function(selections) {
    _.each(selections, function(selection) {
      this.addField(
        this.fieldName,
        selection.id,
        selection.get('name'),
        selection.get('url')
      );
    }, this);
  },

  render: function() {
    this.addEl = $H('li.add', $H('span', 'Add'));
    this.ulEl.append(this.addEl);
    this.ulEl.sortable({items: ':not(.add)'});
    return this;
  }
});
