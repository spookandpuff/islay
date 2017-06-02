/* -------------------------------------------------------------------------- */
/* CHECKBOXES
/* Just a simple jQuery plugin. Call this like so: 
/* $(':checkbox').islayCheckbox()
/* -------------------------------------------------------------------------- */
(function($) {
  var Checkbox = function(input, opts) {
    this.$input = input;
    this.$wrapper = $('<span class="islay-form-checkbox"></span>');
    this.$wrapper.click($.proxy(this, 'toggle'));
    this.$input.change($.proxy(this, 'change'));

    var label = this.$input.parent('label');

    if (opts && opts.mode == 'depressed') {
      this.$text = $('<span class="depressed-text"><i>' + label.text() + '</i></span>');
      this.$wrapper.append(this.$text);
      label.hide();
    }
    else {
      this.$off = $('<span class="off-button"><i class="fa fa-remove"></i></span>');
      this.$on = $('<span class="on-button"><i class="fa fa-check"></i></span>');
      this.$wrapper.append(this.$off, this.$on);
    }

    label.after(this.$wrapper);
    this.$input.hide();
    this.change();
  };

  Checkbox.prototype = {
    change: function() {
      if (this.$input.is(':checked')) {
        this.$wrapper.addClass('on');
        this.$wrapper.removeClass('off');
      } 
      else {
        this.$wrapper.addClass('off');
        this.$wrapper.removeClass('on');
      }

      if (this.$input.is(':disabled')) {
        this.$wrapper.addClass('disabled');
      }
      else {
        this.$wrapper.removeClass('disabled');
      }
    },

    toggle: function() {
      if (!this.$wrapper.is('.disabled')) {
        this.$input.attr('checked', !this.$input.is(':checked'));
        this.$input.trigger('change');
      }
    }
  };

  $.fn.islayCheckbox = function(opts) {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayCheckbox')) {
        $this.data('islayCheckbox', new Checkbox($this, opts));
      }
    });
    return this;
  };
})(jQuery);
