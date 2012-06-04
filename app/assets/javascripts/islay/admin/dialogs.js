/* -------------------------------------------------------------------------- */
/* DIALOG BASE
/* -------------------------------------------------------------------------- */
Islay.Dialogs.Base = Backbone.View.extend({
  className: 'dialog-overlay',
  dimensions: {width: "35em", height: "25em"},
  sizing: 'fixed',

  initialize: function() {
    _.bindAll(this, 'close', '_resize', '_ajaxSuccess');
    if (this.bindings) {_.bindAll(this, bindings);}

    this.dialog = $('div.dialog');
    this.$el(this.dialog);

    this.closeEl = $('div.close', 'Close').click(this.close);
    this.titleEl = $H('div.title', [$('h1', this.titleText), this.closeEl]);
    this.controlsEl = $H('div.controls');
    this.dialog.append(this.titleEl, this.controlsEl);

    this.render();
    $(document.body).append(this.$el);

    if (this.sizing == 'fixed') {
      this.window = $(window).resize(this._resizeFixed);
      this._resizeFixed();
    }
    else {
      this.window = $(window).resize(this._resizeFlexible);
      this._resizeFlexible();
    }

    // if (this.options.url || this.url) do some ajaxy stuff
  },

  show: function() {
    this.$el.show();
  },

  close: function() {
    this.$el.hide();
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
  bindings: ['search', 'filter', 'select', 'deselect', 'add', 'upload'],
  url: '/admin/asset_library/browser.json',
  offset: {x: 30, y: 30},
  sizing: 'flexible',

  loaded: function(res) {
    this.grid.load(latest);
  },

  resize: function(h) {
    this.grid.setHeight(this.toolbar.height() - h);
  },

  select: function(id) {

  },

  deselect: function(id) {
    this.grid.deselect(id);
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
    this.selection  = new Islay.Dialogs.Selection();

    this.toolbar.on('search', this.search);
    this.toolbar.on('filter', this.filter);
    this.grid.on('select', this.select);
    this.selection.on('deselect', this.selection);

    this.controlsEl.append($H('button.upload', 'Upload'), $H('button.add', 'Add'));

    this.dialog.append(this.toolbar, this.grid);

    return this;
  }
});

/* -------------------------------------------------------------------------- */
/* ASSET BROWSER - WIDGETS
/* -------------------------------------------------------------------------- */
Islay.Dialogs.AssetGrid = Backbone.View.extend({
  events: {click: 'click', mousemove: 'mousemove'},
  className: 'grid',
  tagName: 'ul',

  initialize: function() {
    _.bindAll(this, 'hoverIn', 'hoverOut', 'click', 'mousemove');
    this.assets = {};
  },

  load: function(res) {
    this.collection = new Backbone.Collection(res);
    // this.currentAssets
    this.update();
  },

  filter: function(album, filter) {

  },

  update: function() {

  },

  hoverIn: function() {

  },

  hoverOut: function() {

  },

  click: function() {

  },

  mousemove: function() {

  },

  deselect: function(id) {

  },

  setHeight: function(h) {
    this.$el.height(h);
  },

  render: function() {
    // display loading grid by default;

    return this;
  }
});

Islay.Dialogs.AssetEntry = Backbone.View.extend({

});

Islay.Dialogs.AssetToolBar = Backbone.View.extend({
  events: {'.filter li click': 'filter', '.search keyup': search},
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
  },

  height: function() {
    return this.$el.outerHeight();
  },

  render: function() {
    var filters = _.map(this.filterOpts, function(f) {return $H('li', f);});
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
