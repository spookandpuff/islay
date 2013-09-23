/* -------------------------------------------------------------------------- */
/* TOGGLE
/* Simple widget for toggling element visibility.
/* -------------------------------------------------------------------------- */
(function($) {
  var Toggle = function(el) {
    this.$el = el;
    this.$toggle = $('<a class="toggle" href="#"></a>');
    this.$toggle.click($.proxy(this, 'toggle'));
    this.$icon = $('<i class="icon-caret-right"></i>');
    this.$text = $('<span>More</span>');
    this.$toggle.append(this.$icon, this.$text);
    this.$el.before(this.$toggle);
    this.open = false;
    this.$el.hide();
  };

  Toggle.prototype = {
    toggle: function(e) {
      if (this.open) {
        this.$el.hide();
        this.$text.text('More');
        this.$icon.attr('class', 'icon-caret-right');
        this.open = false;
      }
      else {
        this.$el.show();
        this.$text.text('Less');
        this.$icon.attr('class', 'icon-caret-down');
        this.open = true;
      }
      e.preventDefault();
    }
  };

  $.fn.islayToggle = function() {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayToggle')) {
        $this.data('islayToggle', new Toggle($this));
      }
    });
    return this;
  };
})(jQuery);
