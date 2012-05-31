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
    var $input = $el.find('[type!=hidden]:input');
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
        var instance = new Islay.Widgets[widget]({el: el, input: $input});
        obj[$input.attr('id')] = instance;
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

  initialize: function() {
    _.bindAll(this, 'click', 'keyup');

    this.setName();

    this.widget = $H('div.widget.' + this.widgetClass);
    this.hiddenField();
    this.$el.append(this.widget);

    this.data = this.extractData();
    this.removeInput();
  },

  hiddenField: function() {
    this.$hiddenEl = $H('input', {type: 'hidden', name: this.name, value: this.initialValue()});
    this.$el.append(this.$hiddenEl);
  },

  initialValue: function() {
    return this.options.input.val();
  },

  setName: function() {
    this.name = this.options.input.attr('name');
  },

  // Removes the existing input. This is it's own function so that sub-classes
  // can replace it with thier own implementation.
  removeInput: function() {
    this.options.input.remove();
  },

  update: function(value) {
    this.trigger('update', this.name, value);
    this.$hiddenEl.val(value);
  },

  extractData: function() {
    return null;
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

  value: function() {
    this.$hiddenEl.val();
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

  extractData: function() {
    return _.map(this.options.input.find('option'), function(o) {
      var $o = $(o);
      return {text: $o.text(), value: $o.attr('value')};
    });
  },

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

    var currentVal = this.value();
    _.each(this.data, function(entry) {
      if (entry.value === currentVal) {
        this.display = entry.text;
      }
      if (entry.value !== '') {
        this.list.append($H('li', {'data-value': entry.value}, entry.text));
      }
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
      if (this.$hiddenEl.val() == 1) {
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

  render: function() {
    this.optionOff = $H('li.button.optionOff', $H('span', 'x'));
    this.optionOn = $H('li.button.optionOn', $H('span', 't'));
    var frame = $H('ul.frame', [this.optionOff, this.optionOn]);
    this.widget.append(frame);

    // Set initial state
    this.$hiddenEl.val(this.options.input.checked);
    if (this.options.input.checked) {
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

  initialValue: function() {
    return this.$el.find(':radio:checked').val();
  },

  removeInput: function() {
    this.$el.find('label.radio').remove();
  },

  extractData: function() {
    return _.map(this.$el.find('label.radio'), function(label) {
      var $label = $(label);
      return {text: $label.text(), value: $label.find('input').val()};
    });
  },

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
    var value = this.value();
    _.each(this.data, function(entry) {
      var node = $H('li.button', {'data-value': entry.value}, $H('span', entry.text));
      if (value == entry.value) {
        node.addClass('selected');
        this.currentNode = node;
      }
      frame.append(node);
    });

    this.widget.append(frame);

    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* CHECKBOXES
/* -------------------------------------------------------------------------- */
Islay.Widgets.Checkboxes = Islay.Widgets.Base.extend({
  widgetClass: 'checkboxes',

  removeInput: function() {
    this.$el.find('label.checkbox').remove();
  },

  extractData: function() {
    return _.map(this.$el.find('label.checkbox'), function(label) {
      var $label = $(label), input = $label.find('input');
      return {text: $label.text(), name: input.attr('name'), checked: input.checked};
    });
  },

  click: function(e, target) {
    if (target.is('li')) {
      this.highlight(target);
    }
    else if (target.is('span')) {
      this.highlight(target.parent('li'));
    }
  },

  highlight: function(el) {
    if (el.hasClass('selected')) {
      el.removeClass('selected');
    }
    else {
      el.addClass('selected');
    }
  },

  hiddenField: function() {

  },

  render: function() {
    var frame = $H('ul.frame');
    _.each(this.data, function(entry) {
      var attrs = {'data-value': entry.value, name: entry.name};
      var node = $H('li.button', attrs, $H('span', entry.text));
      if (entry.checked) {node.addClass('selected');}
      frame.append(node);
    });

    this.widget.append(frame);

    return this;
  }
});
