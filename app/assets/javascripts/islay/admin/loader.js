var $SP = $SP || {};

(function() {
  var idPattern         = /^#([\w\d\-_]+)/,
      idPatternGroup    = /^#\[([\w\d\s\-_,]+)\]/,
      classPattern      = /(\..+)/,
      classPatternGroup = /\[(.+)\]/,
      groupReplacePattern = /\[.+\]/;

  var LoadHook = function(selectors) {
    var selectorLength = selectors.length;
    this.selectors = [];

    for (var k = selectorLength - 1; k >= 0; k--) {
      var selector = selectors[k];

      var ids = [], classes = [], idMatch, classesMatch;

      // Collect the IDs
      if (idMatch = selector.match(idPattern)) {
        ids.push("#" + idMatch[1]);
      }
      else if (idMatch = selector.match(idPatternGroup)) {
        ids = _.map(idMatch[1].split(', '), function(cls) {
          return '#' + cls;
        });
      }

      // Collect the classes
      if (classesMatch = selector.match(classPattern)) {
        var groupedClasses = classesMatch[1].match(classPatternGroup);
        if (groupedClasses) {
          var original = classesMatch[1],
              entries = groupedClasses[1].split(', '),
              length = entries.length;

          for (var i = length - 1; i >= 0; i--) {
            classes.push(original.replace(groupReplacePattern, entries[i]));
          };
        }
        else {
          classes.push(classesMatch[1]);
        }
      }

      // Check to see if we have to concatenate the IDs and classes or just
      // process one of them.
      var hasIds = ids.length > 0,
          hasClasses = classes.length > 0;

      if (hasIds && hasClasses) {
        for (var i = ids.length - 1; i >= 0; i--) {
          for (var j = classes.length - 1; j >= 0; j--) {
            this.selectors.push(ids[i] + classes[j]);
          };
        };
      }
      else if (hasIds) {
        this.selectors = this.selectors.concat(ids);
      }
      else if (hasClasses) {
        this.selectors = this.selectors.concat(classes);
      }
    }
  };

  LoadHook.prototype = {
    fireOnMatch: function(body) {
      var length = this.selectors.length;
      for (var i = length - 1; i >= 0; i--) {
        if (body.is(this.selectors[i])) {
          this._fire();
          return;
        }
      };
    },

    _fire: function() {
      var arg;
      if (this.selector) {
        arg = $(this.selector);
      }

      // .select('.class', 'derp')
      // Results in a call to $('.class').derp()
      if (arg && this.exec) {
        arg[this.exec]();
      } 
      else {
        if (this.obj) {
          this.instance = new this.obj(arg)
        }
        else if (this.run) {
          this.fn.apply(this.scope, [arg]);
        }
      }
    },

    select: function(selector, exec) {
      this.selector = selector;
      this.exec = exec;
      return this;
    },

    make: function(obj) {
      this.obj = obj;
      return this;
    },

    run: function(fn, scope) {
      this.fn = fn;
      this.scope = scope || this;
      return this;
    }
  };

  var hooks = []

  window.$SP.where = function() {
    var hook = new LoadHook(_.toArray(arguments));
    hooks.push(hook);
    return hook;
  };

  window.$SP.init = function() {
    var body = $(document.body);
    _.each(hooks, function(hook) { hook.fireOnMatch(body) });
  };
})();
