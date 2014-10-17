# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.projects = ->
  tag = $('#project_users')
  if (tag.length)
    users = tag[0].dataset.users.split('|')
    myself = tag[0].dataset.myself

    before_add = (event, ui) ->
      users.indexOf(ui.tagLabel) != -1

    before_remove = (event, ui) ->
      console.log(ui.tag[0])
      its_me = (ui.tagLabel == myself)

      alert 'You need to participate on your own project.' if its_me
      not its_me

    tag.tagit(
      fieldName: 'project[users][]',
      availableTags: users,
      autocomplete: {delay: 0, minLength: 1},
      allowDuplicates: false,
      removeConfirmation: true,
      beforeTagAdded: before_add,
      beforeTagRemoved: before_remove,
      placeholderText: 'Type the user names'
    )
