//= require ./serviceworker-companion.js

import 'semantic-ui-sass'

// "It's not advisable to add code directly here..." bla bla bla... but I did it!! Yeah!!
var alreadyTriedToRegisterNotifications = false
var ready = function() {
  var func = window[document.body.dataset.whoAmI]
  if (func)
    func()

  $(".markdown").each(function(idx, item) {
      item.innerHTML = marked(item.textContent, { sanitize: true })
  })

  // Close semantic-ui stuff
  $(".close.icon").click(function(){
    $(this).parent().hide()
  })
  // Enable dropdowns
  $("select").dropdown()
  $(".dropdown").dropdown()
  // Enable accordions
  $('.ui.accordion').accordion()

  // If we are not in a devise layout
  /*if (!alreadyTriedToRegisterNotifications && document.body.className !== "devise") {
    registerWebPushNotifications();
    alreadyTriedToRegisterNotifications = true
  }*/
}
$(document).on('turbolinks:load', ready)
