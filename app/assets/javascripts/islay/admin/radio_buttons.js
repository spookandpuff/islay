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
    this.segments = {};
    var self = this; // Ugh! fuckin jQuery's scoping bullshit
    var changeProxy = $.proxy(this, 'change');

    el.find(':radio').each(function() {
      var $this = $(this),
          name = $this.attr('value'),
          $label = $this.parent('label'),
          $text = $('<i></i>').text($label.text()),
          $segment = $('<span></span>').attr('data-for', name).append($text);

      self.inputs[name] = $this;
      self.segments[name] = $segment;
      self.$wrapper.append($segment);
      $label.hide();
      self.update($this, $segment);
      $this.on('change', changeProxy);
    });

    this.$wrapper.click($.proxy(this, 'click'));

    el.append(this.$wrapper);
  };

  RadioButtons.prototype = {
    change: function(e) {
      var $target = $(e.target),
          $segment = this.segments[$target.attr('value')];

      this.update($target, $segment);
    },

    update: function($target, $segment) {
      if ($target.is(':checked')) {
        if (this.$current) {this.$current.removeClass('selected');}
        $segment.addClass('selected');
        this.$current = $segment;
      }

      if ($target.is(':disabled')) {
        $segment.addClass('disabled');
      }
      else {
        $segment.removeClass('disabled');
      }
    },

    click: function(e) {
      var $target = $(e.target);
      if (!$target.is('span')) {$target = $target.parent('span');}
      if (!$target.is('.disabled')) {
        this.inputs[$target.attr('data-for')]
            .prop('checked', true)
            .trigger('change');
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
