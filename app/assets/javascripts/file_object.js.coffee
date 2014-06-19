
@new_directory_form_open = ->
  $('div#new_directory_form input#name').val('')
  $('div#new_directory_form').show()
  $('div#new_directory_form input#name').focus()
  return true

@create_new_directory_click = ->
  $.ajax
    type: 'post'
    url: '/create'
    data: name: $('div#new_directory_form input#name').val(), current_directory_id: $('form#file_upload_form input#current_directory_id').val(), current_directory_id_digest: $('form#file_upload_form input#current_directory_id_digest').val()
    success: (response) ->
      $("div#new_directory_form").after(response)
      $("div#new_directory_form").hide()

      return true

  return true

get_file_object_checkeds = ->
  file_object_checkeds = []

  $('input.file_object_checks:checked').each ->
    #alert $(this).val()
    #alert $(this).data('check_id_digest')
    file_object_checkeds.push {id: $(this).val(), id_digest: $(this).data('check_id_digest')}

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

  alert file_object_checkeds

  return if file_object_checkeds.length == 0

  $.ajax
    type: 'post'
    url: '/cut'
    data: file_object_checkeds: file_object_checkeds
    success: (response) ->
      $('div#header button#paste_file_object_click').prop('disabled', false)
      return true

  return true

@paste_file_object_click = ->
  $.ajax
    type: 'post'
    url: '/paste'
    data: current_directory_id: $('form#file_upload_form input#current_directory_id').val(), current_directory_id_digest: $('form#file_upload_form input#current_directory_id_digest').val()
    success: (response) ->
      $('div#header button#paste_file_object_click').prop('disabled', true)
      $('div#new_directory_form').after(response)
      return true

  return true

$ ->
  $('div#new_directory_form input#name').keypress (e) ->
    if e.keyCode == 13
      create_new_directory_click()

  return true
