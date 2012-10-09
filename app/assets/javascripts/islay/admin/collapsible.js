var Islay = window.Islay || {};

Islay.Collapsible = Backbone.View.extend({
  events: {
    'click .collapsible-toggle': 'toggle',
    'click .collapsible-expander': 'expand',
    'click .collapsible-collapser': 'collapse'
  },

  expand: function() {
    this.$el.removeClass('collapsed').addClass('expanded')
    this.$el.find('input:text').first().focus();
  },
  collapse: function() {
    this.$el.addClass('collapsed').removeClass('expanded')
  },
  toggle: function() {
    if (this.$el.is('.collapsed')){
      this.expand();
    } else {
      this.collapse();
    }
  }
});