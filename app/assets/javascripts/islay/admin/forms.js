// View instantiates
// Stubs model
// Iterates over inputs
// Grabs values
// Generates widgets
// Binds change events from widgets to view
// View updates model on change
// Before view submits.
var Islay = {};

// Understands required
Islay.FormModel = Backbone.Model.extend({

});

Islay.Form = Backbone.View.extend({
  events: {submit: 'submit'},

  initialize: function() {
    _.bindAll(this, 'submit');

    this.model = new Islay.FormModel();

    var inputs = this.$el.find('.field')
    this.widgets = _.reduce(inputs, this.initializeWidgets, {}, this);
  },

  initializeWidgets: function(obj, el) {
    var $el = $(el);
    var widget = null;

    var match = $el.attr('class').match(/^field ([\w\d\-_]+) .+$/);

    if (match) {
      switch(match[1]) {
        case 'select':
          widget = 'Select';
        break;
        case 'boolean':
          widget = 'Boolean';
        break;
        case 'radio_buttons':
          widget = 'Segmented';
        break;
        case 'check_boxes':
          widget = 'Checkboxes';
        break;
      }

      if (widget) {
        var instance = new Islay.Widgets[widget]({el: el});
        // obj[$input.attr('id')] = instance;
        instance.render();

        // TODO: Bind widgets to model
      }
    }

    return obj;
  },

  submit: function() {

  }
});

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
    this.$el.find(this.removeSelector).remove();
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
    return this.inputs.val();
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
      fn(i, i.attr('name'), i.attr('value'), i.parent('label').text());
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
    this.button = $H('div.button', $H('span', '>'));
    var frame = $H('div.frame', [this.display, this.button]);
    this.list = $H('ul.list');

    this.widget.append(frame, this.list);

    var currentValue = this.currentValue();
    _.each(this.inputs.find('option'), function(opt) {
      opt = $(opt);
      var value = opt.attr('value'),
          text  = opt.text();

      if (value == currentValue) {this.display.text(text);}
      if (value != '') {this.list.append($H('li', {'data-value': value}, text));}
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
    this.optionOff = $H('li.button.optionOff', $H('span', 'x'));
    this.optionOn = $H('li.button.optionOn', $H('span', 't'));
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
    if (el.hasClass('selected')) {
      this.update(0, el.attr('name'));
      el.removeClass('selected');
    }
    else {
      this.update(1, el.attr('name'));
      el.addClass('selected');
    }
  },

  render: function() {
    var frame = $H('ul.frame');

    this.eachLabelAndInput(function(input, name, value, text) {
      var node = $H('li.button', {'data-value': value, name: name}, $H('span', text));
      if (input.checked) {node.addClass('selected');}
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
