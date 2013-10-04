/* -------------------------------------------------------------------------- */
/* FORM TABS
/* Based on the presence of the .form-tab class on a fieldset, generates a 
/* tab set with nice behaviour for toggling between then. It also generates
/* decent anchors in the location and respects them when initializing.
/* -------------------------------------------------------------------------- */
(function($) {
  var FormTabs = function(form) {
    this.$form = form;
    var fieldsets = this.$form.find('fieldset.form-tab');

    if (fieldsets.length > 0) {
      this.$list = $('<ul class="islay-form-tabs"></ul>');

      // See if there is an anchor in the URL
      var hash = null;
      if (window.location.hash !== "") {hash = window.location.hash;}

      // Generate each tab
      this.tabs = {};
      this.anchors = {};
      _.each(this.$form.find('fieldset.form-tab'), function(el, i) {
        var $fieldset = $(el)
            $legend = $fieldset.children('legend'),
            name = '#' + $fieldset.attr('id') + '-tab',
            $a = $('<a></a>').text($legend.text()).attr('href', name),
            $li = $('<li></li>').append($a);

        this.tabs[name] = $fieldset;
        this.anchors[name] = $a;
        $legend.hide();
        this.$list.append($li);

        if ((hash && hash === name) || (!hash && i === 0)) {
          this.select(name);
        }
        else {
          $fieldset.hide();
        }
      }, this);

      // If we have a dud hash, no tab will be selected, so go back and default
      // to the first one.
      if (!this.current) {this.select(this.$list.find('a').attr('href'));}

      // Append list and set up events
      this.$form.find('#content').prepend(this.$list);
      this.$list.on('click', 'a', $.proxy(this, 'click'));
    }
  };

  FormTabs.prototype = {
    click: function(e) {
      var $target = $(e.target);
      this.select($target.attr('href'));
      return false;
    },

    select: function(name) {
      if (this.current) {
        this.tabs[this.current].hide();
        this.anchors[this.current].removeClass('current');
      }

      this.tabs[name].show();
      this.anchors[name].addClass('current');
      this.current = name;
      window.location.hash = name;
    }
  };

  $.fn.islayFormTabs = function() {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayFormTabs')) {
        $this.data('islayFormTabs', new FormTabs($this));
      }
    });
    return this;
  };
})(jQuery);
