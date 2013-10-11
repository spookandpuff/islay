/* -------------------------------------------------------------------------- */
/* TOGGLE
/* Simple widget for toggling element visibility.
/* -------------------------------------------------------------------------- */
(function($) {
  var Toggle = function(el, opts) {
    this.$el = el;

    if (opts && opts.toggle) {
      this.$toggle = opts.toggle;
    }
    else {
      this.$toggle = $('<a class="toggle" href="#"></a>');
      this.$icon = $('<i class="icon-caret-right"></i>');
      this.$text = $('<span>More</span>');
      this.$toggle.append(this.$icon, this.$text);
      this.$el.before(this.$toggle);
    }

    this.$toggle.click($.proxy(this, 'toggle'));
    this.open = false;
    this.$el.hide();
  };

  Toggle.prototype = {
    toggle: function(e) {
      if (this.open) {
        this.$el.hide();
        if (this.$text) {
          this.$text.text('More');
          this.$icon.attr('class', 'icon-caret-right');
        }
        this.open = false;
      }
      else {
        this.$el.show();
        if (this.$text) {
          this.$text.text('Less');
          this.$icon.attr('class', 'icon-caret-down');
        }
        this.open = true;
      }
      e.preventDefault();
    }
  };

  $.fn.islayToggle = function(opts) {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayToggle')) {
        $this.data('islayToggle', new Toggle($this, opts));
      }
    });
    return this;
  };
})(jQuery);
