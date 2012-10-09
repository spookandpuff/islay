//= require jquery
//= require ./namespace
//= require ../../vendor/underscore
//= require ../../vendor/backbone
//= require ../../vendor/jquery.prettydate
//= require ../../vendor/jquery.sortable
//= require_tree .
//= require_extensions


$SP.where('.[edit, new, create, update]').select('#islay-form').run(function(form) {
  var FormView = new Islay.Form({el: form});
});

$SP.where('.[show, index]').select('table.sortable').run(function(table) {
  var SortableTable = new Islay.SortableTable({el: $(table).closest('form')});
});

$SP.where('.[show, edit]').select('div.collapsible, li.collapsible').run(function(collection) {
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

  $SP.init();
});
