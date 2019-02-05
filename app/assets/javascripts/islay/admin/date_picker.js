/* -------------------------------------------------------------------------- */
/* DATE PICKER
/* A wrapper around a third party date picker.
/* -------------------------------------------------------------------------- */
(function($) {
  var DatePicker = function(input) {
    this.$input = input;
    this.$label = input.siblings('label').first();
    this.$wrapper = $('<span class="islay-form-date-picker"></span>');
    this.$display = $('<span class="display"></span>');
    this.$button = $('<i class="fa fa-calendar button"></i>');
    this.$wrapper.append(this.$display, this.$button);

    this.$wrapper.click($.proxy(this, 'toggle'));
    this.open = false;

    // Check to see if there is a date/time string. Otherwise, default to today.
    var val = this.$input.val().trim();
    if (_.isEmpty(val)) {
      this.update(new Date());
    }
    else {
      this.update(val);
    }

    $(document).click($.proxy(this, 'clickOutside'));

    this.$input.after(this.$wrapper);
    this.$input.hide();
  };

  DatePicker.prototype = {
    toggle: function(e) {
      if (this.$input.attr('disabled') || this.$input.attr('readonly')) {return false}
      if (this.open && this.$picker.has(e.target).length === 0) {
        this.$picker.hide();
        this.open = false;
      }
      else {
        if (!this.picker) {
          this.picker = new Kalendae(this.$wrapper[0], {selected: this.current, useYearNav: this.$input.is('[data-years=true]' || false)});
          this.picker.subscribe('change', $.proxy(this, 'updateFromPicker'));
          this.$picker = $(this.picker.container);
        }
        this.$picker.show();
        this.open = true;
      }
    },

    clickOutside: function(e) {
      if (this.open && !this.$wrapper.is(e.target) && this.$wrapper.has(e.target).length === 0) {
        this.$picker.hide();
        this.open = false;
      }
    },

    update: function(date) {
      var val = moment(date);
      this.current = val;
      this.$display.text(val.format('DD/MM/YYYY'));
      this.$input.val(val.format('YYYY-MM-DD'))
    },

    updateFromPicker: function() {
      var date = this.picker.getSelectedRaw()[0];
      this.update(date);
      this.$picker.hide();
      this.open = false;
    }
  };

  $.fn.islayDatePicker = function() {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayDatePicker')) {
        $this.data('islayDatePicker', new DatePicker($this));
      }
    });
    return this;
  };
})(jQuery);
