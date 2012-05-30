//= require jquery
//= require ../vendor/underscore
//= require ../vendor/backbone
//= require_tree .

$SP.where('.[edit, new]').select('#islay-form').run(function(form) {
  var FormView = new Islay.Form({el: form});
});

$($SP.init);
