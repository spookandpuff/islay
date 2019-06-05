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

  //Apply the currently selected value to the wrapper as a styling hook
  $('body').on('change', '.select-wrapper select', function(e){
    var target = $(e.target),
        wrapper = target.closest('.select-wrapper');

    wrapper.attr('data-' + target.attr('name').replace(/[\[\]]/g, '-'), target.val());
  });

  $.fn.islaySubSelect = function(){
    var child = $(this),
        childOptions = child.find('option[value][value!=""]'),
        parent = $('#' + child.data('sub-set-of'));

        child.on('update.sub-select', function(){
          var scope = parent.find(':selected').attr('value');
          if (scope) {
            //Limit the child options to the selected scope
            child.removeAttr('disabled');
            childOptions.hide();
            childOptions.filter('[data-sub-set-scope=' + scope + ']').show();
            childOptions.filter(':selected:not([data-sub-set-scope=' + scope + '])').removeAttr("selected");
          } else {
            //Disable the child select until a scope is selected
            childOptions.removeAttr("selected").hide();
            child.attr('disabled', 'disabled');
          }

        });

        parent.on('change blur', function(){
          child.trigger('update.sub-select');
        });

        child.trigger('update.sub-select');

    return child;
  }

  $.fn.islaySelect = function(type) {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islaySelect')) {
        $this.data('islaySelect', true);

        if ($this.is('select[data-sub-set-of]')) {
          type = 'sub-set';
        }

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
          case 'sub-set':
            $this.islaySubSelect().wrap('<div class="select-wrapper"></div>');
            break;
          case 'multi':
            $this.select2();
            break;
          default:
            $this.wrap('<div class="select-wrapper"></div>')
            // $this.select2();
            break;
        }
      }
    });
    return this;
  }
})(jQuery);
