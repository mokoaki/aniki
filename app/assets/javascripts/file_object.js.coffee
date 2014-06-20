get_file_object_checkeds = ->
  file_object_checkeds = []

  $('div#files input.file_object_checks:checked').each ->
    file_object_checkeds.push {id: $(this).val(), id_digest: $(this).data('check_id_digest')}

  return file_object_checkeds

@file_object_checkeds_check = ->
  file_object_checkeds = get_file_object_checkeds()

  bool = !(file_object_checkeds.length > 0)
  menu_div = $('div#menu')
  menu_div.find('button#rename_file_object_menu_button').prop('disabled', bool)
  menu_div.find('button#delete_file_object_menu_button').prop('disabled', bool)
  menu_div.find('button#cut_file_object_menu_button').prop('disabled', bool)

@new_directory_menu_button_click = ->
  new_directory_form      = $('div#files div#new_directory_form')
  new_directory_form_name = new_directory_form.find('input#name')

  new_directory_form_name.val('')
  new_directory_form.show()
  new_directory_form_name.focus()

@create_new_directory_click = ->
  new_directory_form          = $('div#files div#new_directory_form')
  new_directory_form_name     = new_directory_form.find('input#name')
  upload_files_form           = $('div#upload')
  current_directory_id        = upload_files_form.find('input#current_directory_id')
  current_directory_id_digest = upload_files_form.find('input#current_directory_id_digest')

  return if $.trim(new_directory_form_name.val()) == ''

  $.ajax
    type: 'post'
    url: '/create'
    data:
      name:                        new_directory_form_name.val()
      current_directory_id:        current_directory_id.val()
      current_directory_id_digest: current_directory_id_digest.val()
    success: (response) ->
      new_directory_form.after(response)
      new_directory_form.hide()

@rename_file_object_menu_button_click = ->
  file_object_checkeds = get_file_object_checkeds()

  for check in file_object_checkeds
    line_div      = $("div#files div#line_#{check.id}")
    name_span     = line_div.find("span#name_object_#{check.id}")
    rename_span   = line_div.find("span#rename_object_#{check.id}")
    name_a        = name_span.find("a#link_#{check.id}")
    rename_input  = rename_span.find("input#rename_#{check.id}")

    rename_input.val(name_a.text())
    name_span.hide()
    rename_span.show()

@rename_karino_name_click = ->
  alert 'wa-i'

@delete_file_object_menu_button_click = ->
  file_object_checkeds = get_file_object_checkeds()

  if window.confirm('チェックしたファイルを削除します')
    $.ajax
      type: 'post'
      url: '/destroy'
      data: file_object_checkeds: file_object_checkeds
      success: (response) ->
        for check in file_object_checkeds
          $("div#files div#line_#{check.id}").remove()

        file_object_checkeds_check()

@cut_file_object_menu_button_click = ->
  file_object_checkeds          = get_file_object_checkeds()
  paste_file_object_menu_button = $('div#menu button#paste_file_object_menu_button')

  $.ajax
    type: 'post'
    url: '/cut'
    data: file_object_checkeds: file_object_checkeds
    success: (response) ->
      paste_file_object_menu_button.prop('disabled', false)

@paste_file_object_menu_button_click = ->
  paste_file_object_menu_button = $('div#menu button#paste_file_object_menu_button')
  new_directory_form            = $('div#files div#new_directory_form')
  upload_files_form             = $('div#upload')
  current_directory_id          = upload_files_form.find('input#current_directory_id')
  current_directory_id_digest   = upload_files_form.find('input#current_directory_id_digest')

  $.ajax
    type: 'post'
    url: '/paste'
    data:
      current_directory_id: current_directory_id.val()
      current_directory_id_digest: current_directory_id_digest.val()
    success: (response) ->
      paste_file_object_menu_button.prop('disabled', true)
      new_directory_form.after(response)

@new_directory_form_name_keypress = ->
  if event.keyCode == 13
    create_new_directory_click()
