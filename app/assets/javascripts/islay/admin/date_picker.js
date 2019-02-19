/* -------------------------------------------------------------------------- */
/* DATE PICKER
/* A wrapper around a third party date picker.
/* -------------------------------------------------------------------------- */
(function($) {
  var DatePicker = function(input) {
    this.$input = input;
    this.$label = input.siblings('label').first();
    this.$wrapper = $('<span class="islay-form-date-picker"></span>');
    this.$display = $('<span class="display"></span>');
    this.$button = $('<i class="fa fa-calendar button"></i>');
    this.$wrapper.append(this.$display, this.$button);

    this.$wrapper.click($.proxy(this, 'toggle'));
    this.open = false;

    // Check to see if there is a date/time string. Otherwise, default to today.
    var val = this.$input.val().trim();
    if (_.isEmpty(val)) {
      this.update(new Date());
    }
    else {
      this.update(val);
    }

    $(document).click($.proxy(this, 'clickOutside'));

    this.$input.after(this.$wrapper);
    this.$input.hide();
  };

  DatePicker.prototype = {
    toggle: function(e) {
      if (this.$input.attr('disabled') || this.$input.attr('readonly')) {return false}
      if (this.open && this.$picker.has(e.target).length === 0) {
        this.close();
      } else {
        if (!this.picker) {
          this.picker = new Kalendae(this.$wrapper[0], {selected: this.current, useYearNav: this.$input.is('[data-years=true]' || false)});
          this.picker.subscribe('change', $.proxy(this, 'updateFromPicker'));
          this.$picker = $(this.picker.container);
        }

        $(document).on('keypress.datePicker', $.proxy(this, 'keyPress'));
        $(window).on('keydown.datePicker', $.proxy(this, 'catchKey'));

        this.$picker.show();
        this.open = true;
      }
    },

    clickOutside: function(e) {
      if (this.open && !this.$wrapper.is(e.target) && this.$wrapper.has(e.target).length === 0) {
        this.close();
      }
    },

    keyPress: function(e) {

      var val = [];

      //The first key press should clear the input
      if (!this.keyEntry()) {
        this.clear();
      } else {
        val = this.$display.text().split('');
      }

      switch (e.key) {
        case '/':
        case '-':
          val.push('/');
          e.preventDefault();
        break;
        default:
          if (e.which >=48 && e.which <=57) {
            //This is 0-9
            val.push(e.key);
          }
        break;
      }

      //Update the user's display with progress
      this.$display.text(val.join(''));

      //Check if we have a complete date
      var date = moment(val.join(''), 'DD/MM/YYYY', true);

      if (date.format() == 'Invalid date') {
        this.$input.val('');
      } else {
        //Update the input, since this looks legit
        this.update(date.format('YYYY-MM-DD'));
        this.$input.data('has-key-entry', false);
      }
    },

    catchKey: function(e) {
      if (e.key === 'Backspace') {
        e.preventDefault();
        this.clear();
        return false;
      }
    },

    keyEntry: function() {
      var result = this.$input.data('has-key-entry') ? true : false;
      this.$input.data('has-key-entry', true);
      return result;
    },

    clear: function(){
      this.$input.val('');
      this.$display.text('');
    },

    close: function(){
      this.$picker.hide();
      this.open = false;

      $(document).off('.datePicker');
      $(window).off('.datePicker');
    },

    update: function(date) {
      var val = moment(date);
      this.current = val;
      this.$display.text(val.format('DD/MM/YYYY'));
      this.$input.val(val.format('YYYY-MM-DD'))
    },

    updateFromPicker: function() {
      var date = this.picker.getSelectedRaw()[0];
      this.update(date);
      this.$picker.hide();
      this.open = false;
    }
  };

  $.fn.islayDatePicker = function() {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayDatePicker')) {
        $this.data('islayDatePicker', new DatePicker($this));
      }
    });
    return this;
  };
})(jQuery);
