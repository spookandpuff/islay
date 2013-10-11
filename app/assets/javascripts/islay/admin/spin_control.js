/* -------------------------------------------------------------------------- */
/* SPIN CONTROL
/* Widget with controls for incrementing and decrementing integer values. Can
/* be configured to:
/* - Only have positive values
/* - Have an upper bound
/* - Show or hide a display for the resulting number
/* -------------------------------------------------------------------------- */
(function($) {
  var SpinControl = function(el, opts) {
    this.$input = el;

    // Set up UI
    this.$up = $H('span.up', $H('i.icon-caret-up'));
    this.$down = $H('span.down', $H('i.icon-caret-down'));
    this.$wrapper = $H('span.islay-form-spin-control', [this.$up, this.$down]);
    this.$input.after(this.$wrapper);

    // Construct defaults
    var defaults = {
      showInput: false,
      lowerBound: 0
    };

    this.opts = opts ? _.extend(defaults, opts) : defaults;

    // Set initial state based on config
    if (this.opts.showInput === false) {
      this.$input.hide();
    }

    // Attach events
    this.$up.click($.proxy(this, 'clickUp'));
    this.$down.click($.proxy(this, 'clickDown'));
    this.$input.on('change', $.proxy(this, 'change'));

    // Trigger change to set the initial state
    this.change();
  };

  SpinControl.prototype = {
    clickUp: function() {
      if (!this.$up.is('.disabled')) {
        this.$input.val(parseInt(this.$input.val()) + 1);
        this.$input.trigger('change');
      }
    },

    clickDown: function() {
      if (!this.$down.is('.disabled')) {
        this.$input.val(parseInt(this.$input.val()) - 1);
        this.$input.trigger('change');
      }
    },

    change: function() {
      if (this.$input.is(':disabled')) {
        this.$down.addClass('disabled');
        this.$up.addClass('disabled');
      }
      else {
        var val = parseInt(this.$input.val());
        if (_.isNumber(this.opts.lowerBound) && val === this.opts.lowerBound) {
          this.$down.addClass('disabled');
          this.$up.removeClass('disabled');
        }
        else if (_.isNumber(this.opts.upperBound) && val === this.opts.upperBound) {
          this.$down.removeClass('disabled');
          this.$up.addClass('disabled');
        }
        else {
          this.$down.removeClass('disabled');
          this.$up.removeClass('disabled');
        }
      }
    }
  };

  $.fn.islaySpinControl = function(opts) {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islaySpinControl')) {
        $this.data('islaySpinControl', new SpinControl($this, opts));
      }
    });
    return this;
  };
})(jQuery);
