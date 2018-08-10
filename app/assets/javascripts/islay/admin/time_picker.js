/* -------------------------------------------------------------------------- */
/* TIME PICKER
/* A wrapper around a third party time picker.
/* -------------------------------------------------------------------------- */
(function($) {
  var IslayTimePicker = function(input) {
    this.$input = input;
    this.$wrapper = $('<span class="islay-form-time-picker"></span>');
    this.$display = $('<span class="display"></span>');
    this.$button = $('<i class="fa fa-clock-o button"></i>');
    this.$wrapper.append(this.$display, this.$button);

    this.$wrapper.click($.proxy(this, 'toggle'));
    this.open = false;

    // Check to see if there is a date/time string. Otherwise, default to today.
    var val = this.$input.val().trim();
    if (_.isEmpty(val)) {
      this.update();
    }
    else {
      this.update(val);
    }

    $(document).click($.proxy(this, 'clickOutside'));

    this.$input.after(this.$wrapper).hide();
  };

  IslayTimePicker.prototype = {
    toggle: function(e) {
      if (this.open && this.$picker.has(e.target).length === 0) {
        this.picker.hide();
        this.open = false;
      }
      else {
        if (!this.picker) {
          this.picker = new TimePicker(this.$wrapper[0], {theme: 'light'});
          this.picker.on('change', $.proxy(this, 'updateFromPicker'));
          this.$picker = $(this.picker.container);
        }
        this.picker.show();
        this.open = true;
      }
    },

    clickOutside: function(e) {
      if (this.open && !this.$wrapper.is(e.target) && this.$wrapper.has(e.target).length === 0) {
        this.$picker.hide();
        this.open = false;
      }
    },

    update: function(time) {
      if (time) {
        var val = moment(time, 'hh:mm a').format('h:mm a');
        this.current = val;
        this.$display.text(val);
        this.$input.val(time).attr('value', time);
      }
    },

    updateFromPicker: function(e) {
      var time = (e.hour || 0) + ':' + (e.minute || 0)
      this.update(time);
      this.$picker.hide();
      this.open = false;
    }
  };

  $.fn.islayTimePicker = function() {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayTimePicker')) {
        $this.data('islayTimePicker', new IslayTimePicker($this));
      }
    });
    return this;
  };
})(jQuery);
