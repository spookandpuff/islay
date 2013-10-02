//= require jquery
//= require ./namespace
//= require ../../vendor/underscore
//= require ../../vendor/backbone
//= require ../../vendor/jquery.prettydate
//= require ../../vendor/jquery.sortable
//= require ../../vendor/select2
//= require ../../vendor/mustache
//= require ../../vendor/jquery.stickytableheaders.min
//= require_tree .
//= require_extensions

$SP.where('.[edit, new, create, update]').select('#islay-form').run(function(form) {
  form.find('.boolean :checkbox').islayCheckbox();
  form.find('.radio_buttons').islayRadioButtons();
  form.find('.select select').islaySelect();
  form.find('.multi_select select').islaySelect();
  form.find('.tree_select select').islaySelect('tree');
  form.find('.multi_asset select').islayAssetPicker('multi');
  form.find('input[name*="tag_summary"]').islaySelect('tags');
  form.find('.date_picker input').islayDatePicker();
  form.find('.islay-toggle').islayToggle();
});

$SP.where('.[show, index]').select('table.sortable').run(function(table) {
  var SortableTable = new Islay.SortableTable({el: $(table).closest('form')});
});

$SP.where('.[show, edit, create, update]').select('div.collapsible, li.collapsible').run(function(collection) {
  _.each(collection, function(collapser){
    var Collapsible = new Islay.Collapsible({el: $(collapser)});
  });
});

$(function() {
  var timeValue = function() {
    return $(this).text();
  };

  $('#content .time').prettyDate({value: timeValue});

  // DELETE DIALOG
  $('#content .delete, #content .delete, #footer .delete').click(function(e){
    var dialog = new Islay.Dialogs.Confirmation({url: e.target.href, title: e.target.title});
    e.preventDefault();
  });

  $('#islay-add-item').on('click', function(e) {
    var $target = $(this);
    if ($target.data('addDialog')) {
      $target.data('addDialog').show();
    }
    else {
      var dialog = new Islay.Dialogs.Add({url: $target.attr('href'), title: $target.attr('title')});
      $target.data('addDialog', dialog);
    }

    e.preventDefault();
  });

  $('.islay-global-search [type="text"]').islaySearch();

  $('button.print').click(function(){window.print()})

  // Where specified, make table headers stick to the top of the screen
  $('#content table.fixed-header').stickyTableHeaders({fixedOffset: $('.islay-layout-header')});

  $SP.init();
});
