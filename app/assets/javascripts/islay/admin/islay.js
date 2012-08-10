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

  $SP.init();
});
