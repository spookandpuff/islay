/* -------------------------------------------------------------------------- */
/* Phone Format
/* Simple widget for prettying up phone numbers
/* -------------------------------------------------------------------------- */
(function($) {
  var FindAsYouType = function(el, opts) {
    var candidates = el.data('candidates');

    el.select2({
      data: candidates,
      initSelection: function(element, callback){
        var data = (_.find(candidates, function(i){
          return i.id == el.val();
        }));
        callback(data)
      }
    })
  };

  $.fn.islayFindAsYouType = function(opts) {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayFindAsYouType')) {
        $this.data('islayFindAsYouType', new FindAsYouType($this, opts));
      }
    });
    return this;
  };
})(jQuery);
