/* -------------------------------------------------------------------------- */
/* PAGE FEATURES
/* A specialised 'widget' that sets up the page features form.
/* -------------------------------------------------------------------------- */
(function($) {
  var PageFeatures = function(el) {
    this.$el = el;

    var features = this.$el.find('.feature'),
        bound = features.length - 1;

    _.each(features, function(el, i) {
      var $el = $(el),
          details = $el.find('.details'),
          toggle = $el.find('legend');

      // Set up the toggle
      details.islayToggle({toggle: toggle});

      // Set up spin control for position
      var position = $el.find('.field.position :input');
      position.islaySpinControl({upperBound: bound, reversed: true});

      // Set up the features for reordering
      position.on('islay.increment', {feature: $el}, $.proxy(this, 'moveDown'));
      position.on('islay.decrement', {feature: $el}, $.proxy(this, 'moveUp'));
    }, this);

    // Rewrite order to initialise positions (this fixes bused orderings)
    this.writeOrder();
  }

  PageFeatures.prototype = {
    moveUp: function(e) {
      if (!this.writingOrder) {
        var $el = e.data.feature;
        $el.prev('.feature').before($el.detach());
        this.postMove($el);
      }
    },

    moveDown: function(e) {
      if (!this.writingOrder) {
        var $el = e.data.feature;
        $el.next('.feature').after($el.detach());
        this.postMove($el);
      }
    },

    writeOrder: function() {
      this.writingOrder = true;
      this.$el.find('.field.position :input').each(function(i, input) {
        $(input).attr('value', i).trigger('change');
      });
      this.writingOrder = false;
    },

    postMove: function(el) {
      el.transition({backgroundColor: 'yellow'}, 500, 'in', function() {
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

