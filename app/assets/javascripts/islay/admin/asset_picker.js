/* -------------------------------------------------------------------------- */
/* ASSET PICKER
/* This mostly leans on the asset dialog and acts as a convenience for
/* initalizing it.
/* -------------------------------------------------------------------------- */
(function($){
  var Picker = function(input, type) {
    this.$input = input;

    // Stub out the UI
    this.$list = $('<ul class="islay-form-asset-picker"></ul>');
    this.$add = $('<li class="add"><i class="fa fa-plus-circle"></i></li>');
    this.$add.click($.proxy(this, 'clickAdd'));
    this.$list.append(this.$add);

    this.clickRemove = $.proxy(this, 'clickRemove');
    this.selectionEnumerator = $.proxy(this, 'selectionEnumerator');

    // Generate entries for existing selections
    this.selected = {};
    var opts = this.$input.find(':selected');
    for (var i = 0; i < opts.length; i++) {
      var $opt = $(opts[i]);
      if (!_.isEmpty($opt.val())) {
        this.addEntry($opt.attr('value'), $opt.attr('data-preview'), $opt.attr('data-format'), $opt);
      }
    };

    // Hide the existing select
    this.$input.after(this.$list).hide();
  };

  Picker.prototype = {
    clickAdd: function() {
      if (this.dialog) {
        this.dialog.show();
      }
      else {
        this.dialog = new Islay.Dialogs.AssetBrowser({
          add: $.proxy(this, 'updateSelection')
        });
      }
    },

    clickRemove: function(e) {
      var $li = $(e.target).parent('li'),
          id = $li.attr('data-value');

      $li.remove();
      this.selected[id].prop('selected', false);
      this.selected[id] = undefined;
    },

    updateSelection: function(selections) {
      $.each(selections, this.selectionEnumerator);
    },

    selectionEnumerator: function(i, selection) {
      if (!this.selected[selection.id]) {
        this.addEntry(selection.id, selection.get('url'), selection.get('data-format'));
      }
    },

    addEntry: function(id, url, format, el) {
      this.selected[id] = el || this.$input.find('option[value="' + id + '"]');
      this.selected[id].prop('selected', true);

      var $li = $('<li class="choice"></li>').attr('data-value', id).attr('data-format', format),
          $img = $('<img>').attr('src', url),
          $name = $('<span class="name">' + el.html() + '</span>');
          $remove = $('<i class="fa fa-times-circle remove"></i>');

      $remove.click(this.clickRemove);
      $li.append($img, $name, $remove);
      this.$add.before($li);
    }
  };

  $.fn.islayAssetPicker = function(type) {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayAssetPicker')) {
        $this.data('islayAssetPicker', new Picker($this, type));
      }
    });

    return this;
  }
})(jQuery);
