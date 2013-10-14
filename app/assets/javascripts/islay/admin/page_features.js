/* -------------------------------------------------------------------------- */
/* PAGE FEATURES
/* A specialised 'widget' that sets up the page features form.
/* -------------------------------------------------------------------------- */
(function($) {
  var PageFeatures = function(el) {
    this.$el = el;
    this.$table = this.$el.find('table');
    var features = this.$table.find('tbody tr');

    _.each(features, function(el, i) {
      // Update legend when title field changes
      var $el = $(el),
          title = $el.find('input[name*=title]'),
          legend = $el.find('legend');

      // Set up the features for reordering
      var position = $el.find('.field.position :input');
      position.on('islay.increment', {feature: $el}, $.proxy(this, 'moveDown'));
      position.on('islay.decrement', {feature: $el}, $.proxy(this, 'moveUp'));

      position.islaySpinControl('config', {lowerBound: 1, upperBound: features.length});
    }, this);

    // Rewrite order to initialise positions (this fixes bused orderings)
    this.writeOrder();
  }

  PageFeatures.prototype = {
    moveUp: function(e) {
      if (!this.writingOrder) {
        var $el = e.data.feature;
        $el.prev('tr').before($el.detach());
        this.postMove($el);
      }
    },

    moveDown: function(e) {
      if (!this.writingOrder) {
        var $el = e.data.feature;
        $el.next('tr').after($el.detach());
        this.postMove($el);
      }
    },

    writeOrder: function() {
      this.writingOrder = true;
      this.$table.find('.field.position :input').each(function(i, input) {
        $(input).attr('value', i + 1).trigger('change');
      });
      this.writingOrder = false;
    },

    postMove: function(el) {
      el.find('td').transition({backgroundColor: 'yellow'}, 500, 'in', function() {
        this.transition({backgroundColor: 'transparent'}, 300);
      });
      this.writeOrder();
    }
  };

  $.fn.islayPageFeatures = function() {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayPageFeatures')) {
        $this.data('islayPageFeatures', new PageFeatures($this));
      }
    });
    return this;
  };
})(jQuery);

