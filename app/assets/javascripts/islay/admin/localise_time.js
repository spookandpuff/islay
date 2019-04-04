/* -------------------------------------------------------------------------- */
/* LOCALISE TIME
/* A simple plugin which localises time strings.
/* -------------------------------------------------------------------------- */
(function($) {
  var localise = function() {
    var $this = $(this),
        original = $this.text(),
        time = moment(original, false);

    if (time && time.isValid()) {
      $this.attr('title', original);
      if ($this.data('format')) {
        $this.text(time.format($this.data('format')));
      } else {
        $this.text(time.calendar());
      }
    }
  };

  $.fn.islayLocaliseTime = function() {
    this.each(localise);
    return this;
  };
})(jQuery);
