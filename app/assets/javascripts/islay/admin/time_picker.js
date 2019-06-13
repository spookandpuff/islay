/* -------------------------------------------------------------------------- */
/* TIME PICKER
/* A wrapper around a third party time picker.
/* -------------------------------------------------------------------------- */
(function($) {
  var IslayTimePicker = function(input) {
    this.$input = input;
    this.$wrapper = $('<span class="islay-form-time-picker"></span>');
    this.$button = $('<i class="fa fa-clock-o button"></i>');
    this.$wrapper.append(this.$button);
    this.open = false;

    this.$input.timeInput()
    this.$wrapper.insertBefore(this.$input);
    this.$input.prependTo(this.$wrapper);
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
