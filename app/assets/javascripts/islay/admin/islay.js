//= require jquery
//= require ../../vendor/underscore
//= require ../../vendor/backbone
//= require ../../vendor/jquery.prettydate
//= require_tree .
//= require_extensions

$SP.where('.[edit, new, create, update]').select('#islay-form').run(function(form) {
  var FormView = new Islay.Form({el: form});
});

$(function() {
  var timeValue = function() {
    return $(this).text();
  };

  $('#content .time').prettyDate({value: timeValue});

  // EDIT DIALOG
  $('#header .new, #content .edit, #footer .edit').click(function(e){
    var dialog = new Islay.Dialogs.Edit({url: e.target.href});
    e.preventDefault();
  });

  // DELETE DIALOG
  $('#content .delete, #content .delete, #footer .delete').click(function(e){
    var dialog = new Islay.Dialogs.Delete({url: e.target.href});
    e.preventDefault();
  });

  $SP.init();
});
