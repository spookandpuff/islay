/* -------------------------------------------------------------------------- */
/* SELECT
/* This is actually just a thin wrapper around Select2. It's main job is to 
/* provide default options and in the case of selects representing trees, 
/* provide a custom template for each option.
/* -------------------------------------------------------------------------- */
(function($){
  // Template for entries in the 'tree' select.
  var template = '<span class="entry depth-{{depth}} disabled-{{disabled}}">' +
                   '<span>{{text}}</span>' +
                 '</span>';

  // Custom rendering for 'tree' selects.
  var formatResult = function(item) {
    var context = {
      text: item.text, 
      disabled: item.disabled, 
      depth: $(item.element).attr('data-depth') || 0
    };

    return Mustache.render(template, context);
  }

  // Used to reject selections for 'disabled' entries.
  var onSelect = function(e) {
    if ($(e.object.element).is('.disabled-true')) {
      e.preventDefault();
    }
  };

  $.fn.islaySelect = function(type) {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islaySelect')) {
        $this.data('islaySelect', true);

        switch(type) {
          case 'tree':
            $this.select2({formatResult: formatResult})
                 .on('select2-selecting', onSelect);
            break;
          case 'tags':
            // TODO: Expand this so it pulls in a known list of tags from 
            // somewhere.
            $this.select2({tags: []});
            break;
          default:
            $this.select2();
            break;
        }
      }
    });
    return this;
  }
})(jQuery);
