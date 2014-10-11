# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.merge_requests = ->
  # Click to add a comment
  $("td > div.add-comment").on 'click', (event) ->
    show_comment_box(event.target.parentElement.parentElement)

  $('#push-comments').on 'click', (event) ->
    false

window.show_comment_box = (tr) ->
  # check if there are comments for this line
  if $(tr).next().hasClass('comment')
    tr = $(tr).next()[0]

  if tr.dataset.expanded == 'true'
    $(tr.nextSibling).find('textarea').focus()
    return
  tr.dataset.expanded = true
  location = tr.dataset.location

  html = "<tr><td colspan='3' class='add-comment'>\
           <textarea placeholder='Leave a comment' name='comments[#{location}]'></textarea>\
           <input type='button' class=reject onclick='hide_comment_box(this);' value=Cancel>
           </td></tr>"
  $(html).insertAfter tr
  $(tr.nextSibling).find('textarea').focus()

window.hide_comment_box = (cancel_link) ->
  tr = cancel_link.parentElement.parentElement
  tr.previousSibling.dataset.expanded = false
  $(tr).remove()

