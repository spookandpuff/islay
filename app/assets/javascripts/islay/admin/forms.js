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
    var $input = $(el).find(':input');
    var widget = null;

    // TODO: Account for groups like radio and checkboxes

    switch($input.prop('nodeName')) {
      case 'SELECT':
        widget = 'Select'
        // Could be one of
        // * select
        // * multi-select
        // * tags*
      break;
      case 'TEXTAREA':
        widget = 'Textarea'
      break;
      case 'INPUT':
        switch($input.attr('type')) {
          case 'file':
            widget = 'File'
          break;
          default:
            widget = 'Text'
          break;
        }
      break;
    }

    var instance = new Islay.Widgets[widget]({el: el, input: $input})

    obj[$input.attr('id')] = instance;

    $input.after(instance.render().el);
    $input.remove();

    // TODO: Bind widgets to model

    return obj;
  },

  submit: function() {

  }
});

Islay.Widgets = Islay.Widgets || {};

Islay.Widgets.Base = Backbone.View.extend({
  events: {click: 'click', keyup: 'keyup'},

  initialize: function() {
    _.bindAll(this, 'click', 'keyup');

    var name = this.options.input.attr('name');
    this.$hiddenEl = $('<input type="hidden" name"' + name + '"/>');
    this.$el.append(this.$hiddenEl);
  },

  render: function() {
    throw "Unimplimented";
  },

  click: function() {
    throw "Unimplimented";
  },

  keyup: function() {
    throw "Unimplimented";
  },

  value: function() {
    this.$hiddenEl.val();
  },

  change: function() {
    this.trigger('change', this.value())
  }
});

Islay.Widgets.Select = Islay.Widgets.Base.extend({
  render: function() {

  }
});


