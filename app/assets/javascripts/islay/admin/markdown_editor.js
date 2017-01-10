/* -------------------------------------------------------------------------- */
/* MARKDOWN EDITOR
/* -------------------------------------------------------------------------- */
(function($){
  var MarkdownEditor = function(input) {
    var me = this;
    this.$input = input;
    this.editorCanvas = $('<div class="markdown-editor-canvas"></div>');

    this.$input.hide();

    this.editorCanvas.html(markdown.toHTML(this.$input.val()));

    input.after(this.editorCanvas);

    this.editor = new MediumEditor(this.editorCanvas[0], {
      placeholder: false,
      extensions: {
        markdown: new MeMarkdown(function (md) {
          me.$input.val(md);
        })
      }
    });
  };

  MarkdownEditor.prototype = {
    
  };

  $.fn.islayMarkdownEditor = function() {
    this.each(function() {
      var $this = $(this);
      if (!$this.data('islayMarkdownEditor')) {
        $this.data('islayMarkdownEditor', new MarkdownEditor($this));
      }
    });

    return this;
  }
})(jQuery);
