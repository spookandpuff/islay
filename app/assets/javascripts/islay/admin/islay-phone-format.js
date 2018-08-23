/* -------------------------------------------------------------------------- */
/* Phone Format
/* Simple widget for prettying up phone numbers
/* -------------------------------------------------------------------------- */
(function($) {
  var PhoneFormat = function(el, opts) {
    this.$el = el;

    this.raw = el.text();
    this.$el.attr('data-raw', this.raw);

    if (this.raw.match(/^04/)) {
      //It's a mobile number
      this.$el.text(this.raw.substring(0, 4) + '\xa0' + this.raw.substring(4, 7) + '\xa0' + this.raw.substring(7))
    } else {
      //Assume landline
      this.$el.text(this.raw.substring(0, 2) + '\xa0' + this.raw.substring(2, 7) + '\xa0' + this.raw.substring(7))
    }
  };

  $.fn.islayPhoneFormat = function(opts) {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayToggle')) {
        $this.data('islayToggle', new PhoneFormat($this, opts));
      }
    });
    return this;
  };
})(jQuery);
