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

    this.config(opts);

    // Set up UI
    if (opts.reversed) {
      this.$up = $H('span.up', $H('i.icon-caret-down'));
      this.$down = $H('span.down', $H('i.icon-caret-up'));
      this.$wrapper = $H('span.islay-form-spin-control', [this.$down, this.$up]);
    } 
    else {

      this.$up = $H('span.up', $H('i.icon-caret-up'));
      this.$down = $H('span.down', $H('i.icon-caret-down'));
      this.$wrapper = $H('span.islay-form-spin-control', [this.$up, this.$down]);
    }

    this.$input.after(this.$wrapper);

    // Attach events
    this.$up.click($.proxy(this, 'clickUp'));
    this.$down.click($.proxy(this, 'clickDown'));
    this.$input.on('change', $.proxy(this, 'change'));

    // Store the existing value for later
    this.previousVal = parseInt(this.$input.val());

    // Trigger change to set the initial state
    this.change();
  };

  SpinControl.prototype = {
    config: function(opts) {
      if (this.opts) {
        this.opts = _.extend(this.opts, opts);
      } else {
        var defaults = {
          showInput: false,
          lowerBound: 0,
          reversed: false
        };

        this.opts = opts ? _.extend(defaults, opts) : defaults;
      }


      // Set initial state based on config
      if (this.opts.showInput === false) {
        this.$input.hide();
      }
    },

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

      var val = parseInt(this.$input.val())
          payload = {previous: this.previousVal, current: val};

      // Check to see if we are incrementing or decrementing and fire the
      // appropriate event.
      if (val > this.previousVal) {
        this.$input.trigger('islay.increment', payload);
        this.previousVal = val;
      }
      else if (val < this.previousVal) {
        this.$input.trigger('islay.decrement', payload);
        this.previousVal = val;
      }


      // Set the state of the controls
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
  };

  $.fn.islaySpinControl = function(run, opts) {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islaySpinControl')) {
        $this.data('islaySpinControl', new SpinControl($this, run));
      } 
      else if (run && opts) {
        $this.data('islaySpinControl')[run](opts);
      }
    });
    return this;
  };
})(jQuery);
