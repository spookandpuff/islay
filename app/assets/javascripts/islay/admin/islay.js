//= require jquery
//= require ../../vendor/underscore
//= require ../../vendor/backbone
//= require_tree .
//= require_extensions

$SP.where('.[edit, new, create, update]', '#islay-shop-admin-products.show').select('#islay-form').run(function(form) {
  var FormView = new Islay.Form({el: form});
});

$($SP.init);
