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

  selected: function(from, id) {
    console.log('selected', from, id);
  },

  unselected: function(from, id) {
    console.log('unselected', from, id);
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
Islay.Dialogs.AssetGrid = Backbone.View.extend({
  className: 'asset-grid',
  tagName: 'ul',

  initialize: function() {
    _.bindAll(this, 'addEntry', 'update', 'selected', 'unselected');
    this.assets = {};
  },

  load: function(res) {
    this.collection = new Backbone.Collection(res);
    this.collection.each(this.addEntry);
  },

  filter: function(album, filter) {
    this.collection.each(this.update);
  },

  update: function(model) {
    var asset = this.assets[model.id];
    if (asset) {
      asset.show();
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

  unselected: function(id) {
    this.trigger('unselected', 'grid', id);
  },

  selected: function(id) {
    this.trigger('selected', 'grid', id);
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

  click: function(e) {
    if (this.selected) {
      this.trigger('unselected', this.model.id);
      this.selected = false;
      this.$el.removeClass('selected');
    }
    else {
      this.trigger('selected', this.model.id);
      this.selected = true;
      this.$el.addClass('selected');
    }
  },

  render: function() {
    var frame = $H('div.frame'),
        // TODO: The json should just give us the preview url directly
        img   = $H('img', {src: this.model.get('preview')['admin_thumb']['url']}),
        name  = $H('span.name', this.model.get('name')),
        type  = $H('span.type', this.model.get('kind'));

    this.$el.append(frame.append(img), name, type);

    return this;
  }
});

/* ASSET TOOLBAR/FILTER/SEARCH */
Islay.Dialogs.AssetToolBar = Backbone.View.extend({
  events: {'click': 'filter', '.search keyup': 'search'},
  className: 'toolbar',
  filterOpts: ['All', 'Images', 'Documents', 'Video', 'Audio'],

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
    this.currentFilter = target.text();
    this.trigger('filter', this.currentAlbum, this.currentFilter);

    this.currentFilterEl.removeClass('selected');
    this.currentFilterEl = target.addClass('selected');
  },

  height: function() {
    return this.$el.outerHeight();
  },

  render: function() {
    var filters = _.map(this.filterOpts, function(f) {return $H('li', f);});
    this.currentFilterEl = filters[0].addClass('selected');
    this.filterEl = $H('ul.filter', filters);
    this.searchEl = $H('input.search[type=text]');

    this.$el.append(this.filterEl, this.searchEl);

    return this;
  }
});

Islay.Dialogs.AssetSelection = Backbone.View.extend({

});

Islay.Dialogs.AssetUploader = Backbone.View.extend({

});
