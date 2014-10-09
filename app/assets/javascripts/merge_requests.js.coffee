# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.merge_requests = ->
  $("td > div.add-comment").on 'click', (event) ->
    show_comment_box(event.target.dataset.line)

show_comment_box = (line) ->
  console.log "add comment on line #{line}"
