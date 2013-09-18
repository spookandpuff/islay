/* -------------------------------------------------------------------------- */
/* SEGMENTED RADIO BUTTONS
/* Restyles a group of radio buttons into a segmented control. To use, call
/* $('.radio-buttons').islayRadioButtons() where the target element is the 
/* parent of multiple radio buttons.
/* -------------------------------------------------------------------------- */
(function($){
  var RadioButtons = function(el) {
    this.$wrapper = $('<span class="islay-form-radio-buttons"></span>');
    this.inputs = {};
    var self = this; // Ugh! fuckin jQuery's scoping bullshit

    el.find(':radio').each(function() {
      var $this = $(this),
          name = $this.attr('value'),
          $label = $this.parent('label'),
          $text = $('<i></i>').text($label.text()),
          $segment = $('<span></span>').attr('data-for', name).append($text);

      self.inputs[name] = $this;
      self.$wrapper.append($segment);
      $label.hide();

      if ($this.is(':checked')) {self.select($segment);}
    });

    this.$wrapper.click($.proxy(this, 'click'));

    el.append(this.$wrapper);
  };

  RadioButtons.prototype = {
    select: function(el) {
      if (this.$current) {this.$current.removeClass('selected');}
      el.addClass('selected');
      this.inputs[el.attr('data-for')].prop('checked', true);
      this.$current = el;
    },

    click: function(e) {
      var $target = $(e.target);
      if ($target.is('span')) {
        this.select($target);
      }
      else {
        this.select($target.parent('span'));
      }
    }
  };

  $.fn.islayRadioButtons = function() {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayRadioButtons')) {
        $this.data('islayRadioButtons', new RadioButtons($this));
      }
    });
    return this;
  }
})(jQuery);
