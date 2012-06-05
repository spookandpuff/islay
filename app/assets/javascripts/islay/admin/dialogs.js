var Islay = window.Islay || {};
Islay.Dialogs = {};

/* -------------------------------------------------------------------------- */
/* DIALOG BASE
/* -------------------------------------------------------------------------- */
Islay.Dialogs.Base = Backbone.View.extend({
  className: 'dialog-overlay',
  dimensions: {width: "35em", height: "25em"},
  sizing: 'fixed',

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
      $.getJSON(url, this._ajaxSuccess);
    }

    this._render();
    this.render();
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

    this.closeEl = $H('div.close', 'Close').click(this.close);
    this.titleEl = $H('div.title', [$H('h1', this.titleText), this.closeEl]);
    this.controlsEl = $H('div.controls');
    this.contentEl = $H('div.content');
    this.dialogEl.append(this.titleEl, this.contentEl, this.controlsEl);

    $(document.body).append(this.$el);
  },

  _ajaxSuccess: function(response) {
    if (this.loaded) {this.loaded(response);}
  },

  _resizeFixed: function() {
    // get the window size title and control sizes
    // Resize the dialog.
    // If it's defined, pass the values onto the resize function.
    var windowHeight, remainingHeight;
    if (this.resize) {this.resize(remainingHeight);}
  },

  _resizeFlexible: function() {
    var windowHeight, remainingHeight;
    if (this.resize) {this.resize(remainingHeight);}
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
  offset: {x: 30, y: 30},
  sizing: 'flexible',

  loaded: function(res) {
    this.grid.load(res);
  },

  resize: function(h) {
    // this.grid.setHeight(this.toolbar.height() - h);
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
      $H('button.upload', 'Upload'),
      $H('button.add', 'Add')
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
      // TODO: filter by album as well
      return (type == 'all' || m.get('kind') == type);
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
    // this.$el.height(h);
  },

  render: function() {
    return this;
  }
});

/* ASSET ENTRY */
Islay.Dialogs.AssetEntry = Backbone.View.extend({
  events: {click: 'click'},
  tagName: 'li',
  className: 'asset',

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
        type  = $H('span.type', this.model.get('kind')),
        preview;

    if (this.model.get('previewable')) {
      preview = $H('img', {src: this.model.get('url')});
    }
    else {
      preview = $H('span', {class: 'no-preview ' + this.model.get('kind') + '-icon'});
    }

    this.$el.addClass(this.model.get('kind'));
    this.$el.append(frame.append(preview), name, type);

    return this;
  }
});

/* ASSET TOOLBAR/FILTER/SEARCH */
Islay.Dialogs.AssetToolBar = Backbone.View.extend({
  events: {'click': 'filter', '.search keyup': 'search'},
  className: 'toolbar',
  filterOpts: {all: 'All', image: 'Images', document: 'Documents', video: 'Video', audio: 'Audio'},

  initialize: function() {
    _.bindAll(this, 'filter', 'search', 'changeAlbum');
    this.currentAlbum = 'Latest';
    this.currentFilter = 'All';
  },

  search: function(e) {

  },

  changeAlbum: function() {
    // Update this.currentAlbum
    this.trigger('filter', this.currentAlbum, this.currentFilter);
  },

  filter: function(e) {
    var target = $(e.target);
    this.currentFilter = target.attr('data-id');
    this.trigger('filter', this.currentAlbum, this.currentFilter);

    this.currentFilterEl.removeClass('selected');
    this.currentFilterEl = target.addClass('selected');
  },

  height: function() {
    return this.$el.outerHeight();
  },

  render: function() {
    var filters = _.map(this.filterOpts, function(f, k) {return $H('li', {'data-id':k}, f);});
    this.currentFilterEl = filters[0].addClass('selected');
    this.filterEl = $H('ul.filter', filters);
    this.searchEl = $H('input.search[type=text]');

    this.$el.append(this.filterEl, this.searchEl);

    return this;
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
      var name = [model.get('name'), $H('span', model.get('kind'))];
      node = $H('li', {'data-id': model.id, class: model.get('kind') + '-icon'}, name);
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