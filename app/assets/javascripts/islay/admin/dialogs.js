var Islay = window.Islay || {};
Islay.Dialogs = {};

/* -------------------------------------------------------------------------- */
/* DIALOG BASE
/* -------------------------------------------------------------------------- */
Islay.Dialogs.Base = Backbone.View.extend({
  className: 'dialog-overlay',
  dimensions: {width: "35em", height: "25em"},
  sizing: 'fixed',
  format: 'JSON',

  initialize: function() {
    _.bindAll(this, 'close', '_resizeFixed', '_resizeFlexible', '_ajaxSuccess');
    if (this.bindings) {
      _.each(this.bindings, function(b) {_.bindAll(this, b);}, this);
    }

    if (this.sizing == 'fixed') {
      this.window = $(window).resize(this._resizeFixed);
    }
    else {
      this.window = $(window).resize(this._resizeFlexible);
    }

    if (this.options.url || this.url) {
      // TODO: Show loading widget
      var url = this.options.url || this.url;
      if (this.format == 'JSON') {
        $.getJSON(url, this._ajaxSuccess);
      }
      else {
        $.get(url, this._ajaxSuccess);
      }
    }

    this._render();
    this.render();
    this.initResize();
  },

  show: function() {
    this.$el.show();
  },

  close: function() {
    this.$el.hide();
  },

  _render: function() {
    this.dialogEl = $H('div.dialog');
    this.$el.append(this.dialogEl);

    this.closeEl = $H('div.close.icon-cancel-circle', 'Close').click(this.close);
    this.titleEl = $H('div.title', [$H('h1', this.titleText), this.closeEl]);
    this.controlsEl = $H('div.controls');
    this.contentEl = $H('div.content');
    this.dialogEl.append(this.titleEl, this.contentEl, this.controlsEl);

    $(document.body).append(this.$el);
  },

  _ajaxSuccess: function(response) {
    if (this.loaded) {this.loaded(response);}
  },

  initResize: function() {
    if (this.sizing == 'fixed') {
      this.dialogEl.css({width: this.size.width, height: this.size.height});
      this._resizeFixed();
    }
    else {
      this.dialogEl.css({left: this.offset.x, top: this.offset.y});
      this._resizeFlexible();
    }
  },

  _resizeFixed: function() {
    // get the window size title and control sizes
    // Resize the dialog.
    // If it's defined, pass the values onto the resize function.
    var left = (this.window.width() - this.dialogEl.width()) / 2,
        top = (this.window.height() - this.dialogEl.height()) / 2;

    this.dialogEl.css({left: left, top: top});
  },

  _resizeFlexible: function() {
    var dialogH = this.window.height() - (this.offset.y * 2),
        dialogW = this.window.width() - (this.offset.x * 2),
        remainingH = dialogH - (this.titleEl.outerHeight() + this.controlsEl.outerHeight());

    this.dialogEl.css({height: dialogH, width: dialogW});
    if (this.resize) {this.resize(remainingH);}
  }
});

/* -------------------------------------------------------------------------- */
/* EDIT DIALOG
/* -------------------------------------------------------------------------- */
Islay.Dialogs.Edit = Islay.Dialogs.Base.extend({
  titleText: 'Edit',
  offset: {x: 30, y: 30},
  sizing: 'flexible',
  format: 'HTML',
  bindings: ['save'],

  loaded: function(res) {
    this.contentEl.append(res);
    this.formEl = this.$el.find('form');
    this.form = new Islay.Form({el: this.formEl});
  },

  save: function() {
    this.formEl.submit();
  },

  render: function() {
    this.cancelEl = $H('button.cancel', 'Cancel').click(this.close);
    this.saveEl = $H('button.save', 'Save').click(this.save);
    this.controlsEl.append(this.cancelEl, this.saveEl)
  }
});

/* -------------------------------------------------------------------------- */
/* DELETE DIALOG
/* -------------------------------------------------------------------------- */
Islay.Dialogs.Delete = Islay.Dialogs.Base.extend({
  titleText: 'Confirm Deletion',
  size: {width: "40em", height: "20em"},
  sizing: 'fixed',
  format: 'HTML',
  bindings: ['delete'],

  loaded: function(res) {
    this.contentEl.append(res);
    this.formEl = this.$el.find('form');
  },

  delete: function() {
    this.formEl.submit();
  },

  render: function() {
    this.cancelEl = $H('button.cancel', 'Cancel').click(this.close);
    this.deleteEl = $H('button.delete', 'Delete').click(this.delete);
    this.controlsEl.append(this.cancelEl, this.deleteEl)
  }
});

/* -------------------------------------------------------------------------- */
/* ASSET BROWSER
/* -------------------------------------------------------------------------- */
Islay.Dialogs.AssetBrowser = Islay.Dialogs.Base.extend({
  events: {'.add click': 'add', '.upload click': 'upload'},
  titleText: 'Choose Assets',
  bindings: ['search', 'filter', 'selected', 'unselected', 'add', 'upload'],
  url: '/admin/library/browser.json',
  offset: {x: 70, y: 70},
  sizing: 'flexible',

  loaded: function(res) {
    this.grid.load(res);
    this.toolbar.load(res['albums']);
  },

  resize: function(h) {
    this.grid.setHeight(h - this.toolbar.$el.outerHeight());
  },

  selected: function(from, model) {
    this.selections = this.selections || {};
    this.selections[model.id] = model;
    this.selection.add(model);
  },

  unselected: function(from, model) {
    delete this.selections[model.id];

    if (from == 'grid') {
      this.selection.removeSelection(model);
    }
    else {
      this.grid.removeSelection(model);
    }
  },

  search: function(term) {

  },

  add: function() {
    if (this.options.add) {
      this.options.add(this.grid.selectedModels());
    }

    this.close();
  },

  upload: function() {

  },

  filter: function(album, filter) {
    this.grid.filter(album, filter);
  },

  render: function() {
    this.toolbar    = new Islay.Dialogs.AssetToolBar();
    this.grid       = new Islay.Dialogs.AssetGrid();
    this.selection  = new Islay.Dialogs.AssetSelection();

    this.toolbar.on('search', this.search);
    this.toolbar.on('filter', this.filter);
    this.grid.on('selected', this.selected);
    this.grid.on('unselected', this.unselected);
    this.selection.on('unselected', this.unselected);

    this.controlsEl.append(
      this.selection.render().el,
      $H('button.add.primary', 'Add').click(this.add)
    );

    this.contentEl.before(this.toolbar.render().el);
    this.contentEl.append(this.grid.render().el);

    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* ASSET BROWSER - WIDGETS
/* -------------------------------------------------------------------------- */
Islay.Dialogs.AssetCollection = Backbone.Collection.extend({
  search: function(term) {

  },

  latest: function() {
    return this.filter(function(m) {return m.get('latest');});
  },

  by: function(album, type) {
    return this.filter(function(m) {
      return (type == 'all' || m.get('kind') == type) &&
             ((album == 'latest' && m.get('latest')) || (album == m.get('album_id')));
    });
  }
});

Islay.Dialogs.AssetGrid = Backbone.View.extend({
  className: 'asset-grid',
  tagName: 'ul',

  initialize: function() {
    _.bindAll(this, 'addEntry', 'update', 'selected', 'unselected');
    this.assets = {};
    this.selections = {};
  },

  selectedModels: function() {
    return _.map(this.selections, function(v) {return v.model;});
  },

  load: function(res) {
    this.collection = new Islay.Dialogs.AssetCollection(res['assets']);
    this.currentAssets = this.collection.latest();
    _.each(this.currentAssets, this.addEntry);
  },

  filter: function(album, filter) {
    _.each(this.currentAssets, function(asset) {
      var view = this.assets[asset.id];
      view.detach();
    }, this);

    var results = this.collection.by(album, filter);
    _.each(results, this.update, this);
  },

  update: function(model) {
    var asset = this.assets[model.id];
    if (asset) {
      this.$el.append(asset.el);
    }
    else {
      this.addEntry(model);
    }
  },

  addEntry: function(model) {
    var entry = new Islay.Dialogs.AssetEntry({model: model});

    entry.on('selected', this.selected);
    entry.on('unselected', this.unselected);

    this.assets[model.id] = entry;

    this.$el.append(entry.render().el);
  },

  removeSelection: function(model) {
    this.selections[model.id].removeSelection();
  },

  unselected: function(view, model) {
    delete this.selections[model.id];
    this.trigger('unselected', 'grid', model);
  },

  selected: function(view, model) {
    this.selections[model.id] = view;
    this.trigger('selected', 'grid', model);
  },

  setHeight: function(h) {
    this.$el.css({height: h});
  },

  render: function() {
    return this;
  }
});

/* ASSET ENTRY */
Islay.Dialogs.AssetEntry = Backbone.View.extend({
  events: {click: 'click'},
  tagName: 'li',

  initialize: function() {
    _.bindAll(this, 'click');
  },

  show: function() {
    this.$el.show();
  },

  hide: function() {
    this.$el.hide();
  },

  detach: function() {
    this.$el.detach();
  },

  removeSelection: function() {
    this.selected = false;
    this.$el.removeClass('selected');
  },

  click: function(e) {
    if (this.selected) {
      this.trigger('unselected', this, this.model);
      this.selected = false;
      this.$el.removeClass('selected');
    }
    else {
      this.trigger('selected', this, this.model);
      this.selected = true;
      this.$el.addClass('selected');
    }
  },

  render: function() {
    var frame = $H('div.frame'),
        name  = $H('span.name', this.model.get('name')),
        type  = $H('span', {class: 'asset ' + this.model.get('kind')}, this.model.get('friendly_kind')),
        preview;

    if (this.model.get('previewable')) {
      preview = $H('img', {src: this.model.get('url')});
    }
    else {
      preview = $H('span', {class: 'no-preview icon-' + this.model.get('kind')});
    }

    this.$el.addClass(this.model.get('kind'));
    this.$el.append(frame.append(preview), name, type);

    return this;
  }
});

/* ASSET TOOLBAR/FILTER/SEARCH */
Islay.Dialogs.AssetToolBar = Backbone.View.extend({
  className: 'toolbar',

  initialize: function() {
    _.bindAll(this, 'filter');
    this.currentAlbum = 'Latest';
    this.currentFilter = 'All';
  },

  load: function(albums) {
    this.albums.load(albums);
  },

  filter: function(filter) {
    // TODO: Collect the state from the search widget
    this.trigger('filter', this.albums.state(), this.filters.state());
  },

  height: function() {
    return this.$el.outerHeight();
  },

  render: function() {
    this.albums = new Islay.Dialogs.AssetAlbums();
    this.albums.on('filter', this.filter);

    this.filters = new Islay.Dialogs.AssetFilters();
    this.filters.on('filter', this.filter);

    this.$el.append(this.albums.render().el, this.filters.render().el);

    return this;
  }
});

Islay.Dialogs.AssetAlbums = Backbone.View.extend({
  events: {click: 'click'},
  className: 'albums',

  initialize: function() {
    _.bindAll(this, 'click');
    this.currentAlbum = 'latest';
  },

  load: function(albums) {
    _.each(albums, function(a) {
      var count = $H('span.count', a['count']),
          opts  = {'data-id': a['id']},
          node  = $H('li', opts, [a['name'], count]);

      this.listEl.append(node);
    }, this);

    this.listEl.prepend($H('li[data-id=latest]', 'Latest'));
  },

  state: function() {
    return this.currentAlbum;
  },

  click: function(e) {
    var target = $(e.target);
    if (target.is('li')) {
      this.currentAlbum = target.attr('data-id');
      this.displayEl.html(target.html());
      this.trigger('filter');
    }
    this.toggle();
  },

  toggle: function() {
    if (this.open) {
      this.open = false;
      this.$el.removeClass('open')
      this.listEl.hide();
    }
    else {
      this.open = true;
      this.$el.addClass('open')
      this.listEl.show();
    }
  },

  render: function() {
    this.listEl = $H('ul').hide();
    this.displayEl = $H('div.display', 'Latest');
    var button = $H('div.button', $H('span', '↓'));

    this.$el.append(this.displayEl, button, this.listEl);

    return this;
  },
});

Islay.Dialogs.AssetFilters = Backbone.View.extend({
  events: {click: 'click'},
  className: 'filters',
  tagName: 'ul',
  filterOpts: {all: 'All', image: 'Images', document: 'Documents', video: 'Video', audio: 'Audio'},

  initialize: function() {
    _.bindAll(this, 'click');
    this.currentFilter = 'all';
  },

  state: function() {
    return this.currentFilter;
  },

  click: function(e) {
    var target = $(e.target);
    if (target.is('a')) {
      this.currentFilter = target.attr('data-id');
      this.trigger('filter');

      this.currentEl.removeClass('current');
      this.currentEl = target.addClass('current');
    }
  },

  render: function() {
    _.each(this.filterOpts, function(f, k) {
      var node = $H('a', {'data-id':k}, f);
      if (!this.currentEl) {this.currentEl = node.addClass('current');}
      this.$el.append($H('li', node));
    }, this);

    return this
  }
});

Islay.Dialogs.AssetSelection = Backbone.View.extend({
  events: {'click': 'click'},
  className: 'selection',
  tagName: 'ul',

  initialize: function() {
    _.bindAll(this, 'click');
    this.entries = {};
  },

  add: function(model) {
    var node;
    if (this.entries[model.id]) {
      node = this.entries[model.id]['node'];
    }
    else {
      var name = [model.get('name'), $H('span', model.get('friendly_kind'))];
      node = $H('li', {'data-id': model.id, class: 'asset ' + model.get('kind')}, name);
      this.entries[model.id] = {node: node, model: model};
    }
    this.$el.append(node);
  },

  removeSelection: function(model) {
    this.entries[model.id]['node'].detach();
  },

  click: function(e) {
    var target = $(e.target);
    if (target.is('span')) {target = target.parent();}
    target.detach();
    var model = this.entries[target.attr('data-id')]['model'];
    this.trigger('unselected', 'selection', model);
  }
});

Islay.Dialogs.AssetUploader = Backbone.View.extend({

});
