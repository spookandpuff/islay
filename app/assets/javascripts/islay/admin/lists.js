var Islay = window.Islay || {};

Islay.SortableTable = Backbone.View.extend({
  events: {submit: 'submit', select_all: 'select_all'},

  initialize: function() {
   $this = this;
    this.toggles = [];
    this.selectAllControl = this.$el.find('thead input.toggle');

    _.bindAll(this, 'childSelect', 'childDeselect', 'updateFormState');

    _.each(this.$el.find('tbody input.toggle'), function(e){
      //Initialise a toggle for each toggleable row in the table
      el = $(e).closest('tr');

      var toggleRow = new Islay.SortableTableToggle({el: el});

          toggleRow.on('select deselect', this.updateFormState);
          toggleRow.on('select', this.childSelect);
          toggleRow.on('deselect', this.childDeselect);

      this.toggles.push(toggleRow);
    }, this);

    this.selectAllControl
      .change(function(e){
        $this.toggle_all($(e.target).is(':checked'));
        $this.updateFormState();
      })
      .on('update', function(e, state){
        if (state) {
          $(this).attr('checked', 'checked');
        } else {
          $(this).removeAttr('checked');
        }
      });

      this.updateFormState();
  },
  updateFormState: function() {
    var anySelected = false;
    _.each(this.toggles, function(t){
      if (t.toggleControl.is(':checked')) {
        anySelected = true;
        return false;
      }
    });
    if (anySelected) {
      this.$el.addClass('has-selection');
    } else {
      this.$el.removeClass('has-selection');
    }
  },
  childSelect: function(){
    var allSelected = true;
    _.each(this.toggles, function(e){
      if (!e.$el.is('.selected')) {
        allSelected = false;
        return false;
      }
    });
    this.selectAllControl.trigger('update', allSelected);
  },
  childDeselect: function(){
    this.selectAllControl.trigger('update', false);
  },
  toggle_all: function(state) {
    if (state) {
      this.select_all();
    } else {
      this.deselect_all();
    }
  },
  select_all: function() {
    _.each(this.toggles, function(e){
      e.select();
    });
  },
  deselect_all: function() {
    _.each(this.toggles, function(e){
      e.deselect();
    });
  },
  submit: function() {
    //TODO: Look at AJAX'ing the position update.
  }
});

Islay.SortableTableToggle = Backbone.View.extend({
  events: {'change .toggle': 'toggle'},

  initialize: function() {
    this.toggleControl = this.$el.find('.toggle');
    if (this.toggleControl.is(':checked')) {
      this.select();
    }
  },

  toggle: function() {
    if (this.toggleControl.is(':checked')) {
      this.select();
      this.trigger('select');
    } else {
      this.deselect();
      this.trigger('deselect');
    }
  },

  select: function() {
    this.$el.addClass('selected');
    this.toggleControl.attr('checked', 'checked');
  },

  deselect: function() {
    this.$el.removeClass('selected');
    this.toggleControl.removeAttr('checked');
  }
});
