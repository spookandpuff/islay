var Islay = window.Islay || {};

Islay.TableRowToggle = Backbone.View.extend({
  events: {
    'click .child-row-toggle': 'toggle'
  },

  expand: function() {
    var childRow = this.$el.next('tr.child-row');
    this.$el.find('.child-row-toggle').hide();
    childRow.addClass('child-row-expanded').find('input:text, textarea').first().focus()
  },
  collapse: function() {
    this.$el.next('tr.child-row').removeClass('child-row-expanded')
  },
  toggle: function() {
    var childRow = this.$el.next('tr.child-row');
    if (childRow.is('.child-row-expanded')){
      this.collapse();
    } else {
      this.expand();
    }
    return false;
  }
});
