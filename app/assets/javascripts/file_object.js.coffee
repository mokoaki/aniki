
@new_directory_form_open = ->
  $('div#new_directory_form input#name').val('')
  $('div#new_directory_form').show()
  $('div#new_directory_form input#name').focus()
  return true

@create_new_directory_click = ->
  $.ajax
    type: 'post'
    url: '/create'
    data: name: $('div#new_directory_form input#name').val(), parent_directory_id: $('div#new_directory_form input#parent_directory_id').val()
    success: (response) ->
      $("div#new_directory_form").after(response)
      $("div#new_directory_form").hide()

      return true

  return true

get_file_object_checkeds = ->
  file_object_checkeds = []

  $('input.file_object_checks:checked').each ->
    file_object_checkeds.push $(this).val()

  return file_object_checkeds

@delete_file_object_click = ->
  file_object_checkeds = get_file_object_checkeds()

  return true if file_object_checkeds.length == 0

  if window.confirm('チェックしたファイルを削除します')
    $.ajax
      type: 'post'
      url: '/destroy'
      data: file_object_checkeds: file_object_checkeds
      success: (response) ->
        for id in file_object_checkeds
          $("div#files div#line_#{id}").remove()

        return true

  return true

@cut_file_object_click = ->
  file_object_checkeds = get_file_object_checkeds()

  return if file_object_checkeds.length == 0

  $.ajax
    type: 'post'
    url: '/cut'
    data: file_object_checkeds: file_object_checkeds
    success: (response) ->
      $('div#header button#paste_file_object_click').prop('disabled', false)
      return true

  return true

@paste_file_object_click = (directory_id) ->
  $.ajax
    type: 'post'
    url: '/paste'
    data: directory_id: directory_id
    success: (response) ->
      $('div#header button#paste_file_object_click').prop('disabled', true)
      $('div#new_directory_form').after(response)
      return true

  return true
