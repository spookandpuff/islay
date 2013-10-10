/* -------------------------------------------------------------------------- */
/* LOCALISE TIME
/* A simple plugin which localises time strings.
/* -------------------------------------------------------------------------- */
(function($) {
  var localise = function() {
    var $this = $(this),
        original = $this.text(),
        time = moment(original).lang('en');

    $this.attr('title', original);
    $this.text(time.calendar());
  };

  $.fn.islayLocaliseTime = function() {
    this.each(localise);
    return this;
  };
})(jQuery);
