
@new_directory_form_open = ->
  $('div#new_directory_form input#file_object_name').val('')
  $('div#new_directory_form').show()
  return true

get_file_object_checkeds = () ->
  file_object_checkeds = []

  $('input.file_object_checks:checked').each ->
    file_object_checkeds.push $(this).val()

  return file_object_checkeds

@delete_file_object_click = ->
  if window.confirm('チェックしたファイルを削除します')
    delete_file_object()    

delete_file_object = ->
  file_object_checkeds = get_file_object_checkeds()

  $.ajax
    type: 'post'
    url: '/fo_destroy'
    data: file_object_checkeds: file_object_checkeds
    success: (response) ->
      for id in file_object_checkeds
        $("div#files div#line_#{id}").remove()

      return true

  return true



# @new_directory_create = () ->
#   $.ajax
#     type: 'post'
#     url: '/directories'
#     data: name: 'moko', parent_directory_id: 1
#     success: (response) ->
#       $('div#new_directory_form').after(response)
#       $('div#new_directory_form').empty()
#       return true
#
#   return true
