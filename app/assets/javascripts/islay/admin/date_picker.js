/* -------------------------------------------------------------------------- */
/* DATE PICKER
/* A wrapper around a third party date picker.
/* -------------------------------------------------------------------------- */
(function($) {
  var DatePicker = function(input) {
    this.$input = input;
    this.$wrapper = $('<span class="islay-form-date-picker"></span>');
    this.$display = $('<span class="display"></span>');
    this.$button = $('<i class="icon-calendar button"></i>');
    this.$wrapper.append(this.$display, this.$button);

    this.$wrapper.click($.proxy(this, 'toggle'));
    this.open = false;
    this.update(this.$input.val());

    this.$input.after(this.$wrapper).hide();
  };

  DatePicker.prototype = {
    toggle: function() {
      if (this.open) {
        this.$picker.hide();
        this.open = false;
      }
      else {
        if (!this.picker) {
          this.picker = new Kalendae(this.$wrapper[0], {selected: this.current});
          this.picker.subscribe('change', $.proxy(this, 'updateFromPicker'));
          this.$picker = $(this.picker.container);
        }
        this.$picker.show();
        this.open = true;
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
      this.toggle();
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
