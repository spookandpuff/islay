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
    var $input = $(el).find('[type!=hidden]:input');
    var widget = null;

    // TODO: Account for groups like radio and checkboxes

    switch($input.prop('nodeName')) {
      case 'SELECT':
        widget = 'Select'
      break;
      case 'INPUT':
        switch($input.attr('type')) {
          case 'checkbox':
            widget = 'Boolean'
          break;
        }
      break;
    }

    if (widget) {
      var instance = new Islay.Widgets[widget]({el: el, input: $input})
      obj[$input.attr('id')] = instance;
      instance.render();

      // TODO: Bind widgets to model

    }

    return obj;
  },

  submit: function() {

  }
});

Islay.Widgets = Islay.Widgets || {};

Islay.Widgets.Base = Backbone.View.extend({
  events: {'click': 'click', keyup: 'keyup'},

  initialize: function() {
    _.bindAll(this, 'click', 'keyup');

    this.name = this.options.input.attr('name');
    this.$hiddenEl = $('<input type="hidden" name="' + this.name + '"/>');
    this.$hiddenEl.val(this.options.input.val());
    this.$el.append(this.$hiddenEl);
    this.options.input.remove();
    this.data = this.extractData();
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
  }
});

/* -------------------------------------------------------------------------- */
/* SIMPLE SELECT
/* -------------------------------------------------------------------------- */
Islay.Widgets.Select = Islay.Widgets.Base.extend({
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

  click: function(e) {
    var target = $(e.target);

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

    this.widget = $H('div.widget.select', [frame, this.list]);

    var currentVal = this.value();
    _.each(this.data, function(entry) {
      if (entry.value === currentVal) {
        this.display = entry.text;
      }
      if (entry.value !== '') {
        this.list.append($H('li', {'data-value': entry.value}, entry.text));
      }
    }, this);

    this.$el.append(this.widget);

    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* BOOLEAN SWITCH
/* -------------------------------------------------------------------------- */
Islay.Widgets.Boolean = Islay.Widgets.Base.extend({
  click: function(e) {
    var target = $(e.target);

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
    this.widget = $H('div.widget.boolean', frame);
    this.$el.append(this.widget);

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
