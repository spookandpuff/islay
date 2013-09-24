/* -------------------------------------------------------------------------- */
/* CHECKBOXES
/* Just a simple jQuery plugin. Call this like so: 
/* $(':checkbox').islayCheckbox()
/* -------------------------------------------------------------------------- */
(function($) {
  var Checkbox = function(input) {
    this.$input = input;
    this.$off = $('<span class="off"><i class="icon-remove"></i></span>');
    this.$on = $('<span class="on"><i class="icon-ok"></i></span>');

    this.$wrapper = $('<span class="islay-form-checkbox"></span>');
    this.$wrapper.append(this.$off, this.$on);

    this.$off.click($.proxy(this, 'clickOff'));
    this.$on.click($.proxy(this, 'clickOn'));
    this.$input.change($.proxy(this, 'change'));

    this.$input.parent('label').after(this.$wrapper);
    this.$input.hide();

    this.change();
  };

  Checkbox.prototype = {
    change: function() {
      if (this.$input.is(':checked')) {
        this.$on.addClass('selected');
        this.$off.removeClass('selected');
      } 
      else {
        this.$off.addClass('selected');
        this.$on.removeClass('selected');
      }

      if (this.$input.is(':disabled')) {
        this.$wrapper.addClass('disabled');
      }
      else {
        this.$wrapper.removeClass('disabled');
      }
    },

    clickOn: function() {
      if (!this.$wrapper.is('.disabled')) {
        this.$input.prop('checked', true);
        this.$input.trigger('change');
      }
    },
    clickOff: function() {
      if (!this.$wrapper.is('.disabled')) {
        this.$input.prop('checked', false);
        this.$input.trigger('change');
      }
    }
  };

  $.fn.islayCheckbox = function() {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayCheckbox')) {
        $this.data('islayCheckbox', new Checkbox($this));
      }
    });
    return this;
  };
})(jQuery);
