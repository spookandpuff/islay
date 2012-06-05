(function() {
  var tagPattern        = /^[\w\d\-_]+/,
      selectorPattern   = /(#[\w\d\-_]+|\.[\w\d\-_]+|\[.+\])/g,
      attributePattern  = /\[(.+)=(.+)\]/;

  window.$H = function(selector, opts_or_content, content) {
    var tagName = selector.match(tagPattern)[0];
    var tag = $(document.createElement(tagName));

    // Check for ID, class and attribute declarations
    var parts = selector.match(selectorPattern);
    if (parts) {
      var length = parts.length;
      for (var i = length - 1; i >= 0; i--) {
        switch(parts[i][0]) {
          case '#':
            tag.attr('id', parts[i].split('#').pop());
          break;
          case '.':
            tag.addClass(parts[i].split('.').pop());
          break;
          case '[':
            var attrs = parts[i].match(attributePattern);
            tag.attr(attrs[1], attrs[2]);
          break
        }
      };
    }

    if (opts_or_content) {
      if (opts_or_content.constructor === Object) {
        tag.attr(opts_or_content);
      }
      else {
        content = opts_or_content;
      }
    }

    if (content) {
      switch(content.constructor) {
        case $:
          tag.append(content);
        break;
        case Array:
          tag.append.apply(tag, content);
        break;
        case String:
        case Number:
          tag.append(document.createTextNode(content));
        break
      }
    }

    return tag;
  }
})();
