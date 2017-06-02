/* -------------------------------------------------------------------------- */
/* GLOBAL SEARCH
/* -------------------------------------------------------------------------- */
(function($) {
  var Search = function(input) {
    this.$input = input;
    this.$close = $('<i class="fa fa-remove-sign close"></i>').hide();
    this.$resultsContainer = $('<li class="islay-global-search-results"></li>').hide();
    this.$results = $('<ul></ul>');
    this.$resultsContainer.append(this.$results);
    this.$list = input.closest('ul');

    this.$input.on('focus', $.proxy(this, 'focus'));
    this.$input.on('blur', $.proxy(this, 'blur'));
    this.$input.on('keyup', $.proxy(this, 'keyup'));
    this.$input.on('keydown', $.proxy(this, 'keydown'));
    this.$close.on('click', $.proxy(this, 'close'));

    this.$input.after(this.$close);
    this.$input.closest('li').after(this.$resultsContainer);

    this.selectedIndex = null;

    // Check to see if the nav should stay open when searching is complete.
    this.shouldClose = !this.$list.is('.open');

    // Bind update to preserve scope when using it as an AJAX callback.
    this.update = $.proxy(this, 'update');
  };

  Search.prototype = {
    update: function(response) {
      this.$results.empty();
      this.entries = [];
      this.selectedIndex = null;
      _.each(response, function(r) {
        var $anchor = $('<a class="search-entry"><strong>' + r.name + '</strong><span>' + r.type + '</span></a>');
        var $result = $('<li class="result"></li>');
        $anchor.attr('href', r.url)
        $result.append($anchor);
        this.$results.append($result);
        this.entries.push($result);
      }, this);
    },

    // Supress default browser behavious on key up, down and enter.
    keydown: function(e) {
      switch(e.keyCode) {
        case 38:
        case 40:
        case 13:
          return false;
      }
    },

    keyup: function(e) {
      switch(e.keyCode) {
        case 38:
          this.handleUp();
          break;
        case 40:
          this.handleDown();
          break;
        case 13:
          this.handleEnter();
          break;
        default:
          this.handleSearch();
          break;
      }
    },

    handleSearch: function() {
      var val = this.$input.val();
      if (val.length > 0) {
        $.getJSON('/admin/search', {term: val}).done(this.update);
      }
    },

    handleEnter: function() {
      if (this.selectedIndex !== null) {
        // This is crude, but 'click' does not want to work
        var url = this.entries[this.selectedIndex].find('a').attr('href');
        window.location = url;
      }
    },

    handleUp: function() {
      if (this.entries.length > 0 && this.selectedIndex !== null && this.selectedIndex !== 0) {
        var index = this.selectedIndex - 1;
        this.entries[this.selectedIndex].find('a').removeClass('current');
        this.entries[index].find('a').addClass('current');
        this.selectedIndex = index;
      }
    },

    handleDown: function() {
      if (this.entries.length > 0) {
        if (this.selectedIndex !== null) {
          var index = this.selectedIndex + 1;
          if (index !== this.entries.length) {
            this.entries[this.selectedIndex].find('a').removeClass('current');
            this.entries[index].find('a').addClass('current');
            this.selectedIndex = index;
          }
        }
        else {
          this.selectedIndex = 0;
          this.entries[0].find('a').addClass('current');
        }
      }
    },

    focus: function() {
      this.$close.show();
      this.$list.addClass('open').addClass('searching');
      this.$resultsContainer.show();
    },

    close: function() {
      this.$input.val('');
      this.$close.hide();
      this.$list.removeClass('searching');
      if (this.shouldClose) {this.$list.removeClass('open');}
      this.$resultsContainer.hide();
      this.$results.empty();
      this.selectedIndex = null;
    }
  };

  $.fn.islaySearch = function() {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islaySearch')) {
        $this.data('islaySearch', new Search($this));
      }
    });
    return this;
  };
})(jQuery);
