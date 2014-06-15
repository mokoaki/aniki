# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@new_directory = (directory_id) ->
  $.ajax
    type: 'post'
    data: directory_id: directory_id
    url: '/new_directory_form'
    success: (response) ->
      $('div#new_directory_form').html(response)
      return true

  return true

@new_directory_create = () ->
  $.ajax
    type: 'post'
    url: '/directories'
    data: name: $('input#new_directory_name').val(), parent_directory_id: $('input#new_directory_parent_directory_id').val()
    success: (response) ->
      $('div#new_directory_form').after(response)
      $('div#new_directory_form').empty()
      return true

  return true
