# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.merge_requests = ->
  # Click to add a comment
  $("td > div.add-comment").on 'click', (event) ->
    show_comment_box(event.target.parentElement.parentElement)

window.show_comment_box = (tr) ->
  # check if there are comments for this line
  extraCss = ''
  if $(tr).next().hasClass('comment')
    tr = $(tr).next()[0]
    extraCss = 'reply'

  if tr.dataset.expanded == 'true'
    $(tr.nextSibling).find('textarea').focus()
    return
  tr.dataset.expanded = true
  location = tr.dataset.location

  html = "<tr><td colspan='3' class='add-comment #{extraCss}'>\
           <textarea placeholder='Leave a comment' name='comments[#{location}]'></textarea>\
           <input type='button' class=reject onclick='hide_comment_box(this);' value=Cancel>
           </td></tr>"
  $(html).insertAfter tr
  $(tr.nextSibling).find('textarea').focus()

window.hide_comment_box = (cancel_link) ->
  tr = cancel_link.parentElement.parentElement
  tr.previousSibling.dataset.expanded = false
  $(tr).remove()

window.update_ci_status = (data) ->
  ci_status = $('#ci_status')
  ci_status.removeClass('fa-refresh fa-spin ')
  switch data['status']
    when 'failed'
      ci_status.addClass('fa-bug fail')
    when 'success'
      ci_status.addClass('fa-check ok')
    when 'unknown'
      ci_status.addClass('fa-question')
    else
      ci_status.addClass('fa-gears')

  ci_status.on 'click', (event) ->
    if data['url']
      window.open(data['url'], data['url'])
    else
      alert('Unable to connect to CI.')
