// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//
// Vendor assets
//= require tipped
//= require imagesloaded.pkgd.min
//= require marked.min
//= require simplemde.min
//= require jquery-ui.min
//= require highcharts
//= require tag-it
//= require select2.full
//
//= require_tree .

// "It's not advisable to add code directly here..." bla bla bla... but I did it!! Yeah!!
var ready = function() {
  var func = window[document.body.dataset.whoAmI];
  if (func)
    func();

  $(".tipped").each(function(idx, item) {
    Tipped.create(item, item.dataset.tip);
  });

  $(".markdown").each(function(idx, item) {
      item.innerHTML = marked(item.textContent);
  });

  $('.select2select').select2({
    allowClear: true,
    placeholder: 'Select one',
  });

}
$(document).ready(ready);
$(document).on('page:load', ready);
