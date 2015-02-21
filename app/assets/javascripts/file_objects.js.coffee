# $ ->
#   update_parent_directories_list = (current_directory_id_hash) ->
#     $('#current_directory_id_hash').val(current_directory_id_hash)
#     $('#parent_directories_list').load('parent_directories_list', { file_object_id_hash: current_directory_id_hash })
#
#     true
#
#   update_current_files_list = (current_directory_id_hash) ->
#     $('#current_files_list').load(
#       'current_files_list',
#       { file_object_id_hash: current_directory_id_hash },
#       ->
#         menu_button_update()
#     )
#
#     true
#
#   get_checked_object_id_hashes = ->
#     checkeds = []
#
#     $('input.object_check:checked').each ->
#       checkeds.push $(this).val()
#
#     checkeds
#
#   menu_button_update = ->
#     file_object_checkeds = get_checked_object_id_hashes()
#     check_bool = !(file_object_checkeds.length > 0)
#
#     $('#menu_upload_file_button').prop('disabled', false)
#     $('#menu_new_directory_button').prop('disabled', false)
#     $('#menu_rename_file_object_button').prop('disabled', check_bool)
#     $('#menu_cut_file_object_button').prop('disabled', check_bool)
#     $('#menu_paste_file_object_button').prop('disabled', !($('#proc_mode').val() == 'object_cut'))
#     $('#menu_delete_file_object_button').prop('disabled', check_bool)
#     $('#menu_edit_user_data_button').prop('disabled', false)
#
#     $('div.table').removeClass('opacity')
#
#     if $('#proc_mode').val() == 'object_cut'
#       file_objects_id_hashes = $('#checked_object_id_hashes').val().split(',')
#       for file_object_id_hash in file_objects_id_hashes
#         $('div#' + file_object_id_hash).addClass('opacity')
#
#     $('img#spinner').hide()
#
#     true
#
#   $(document).on 'click', '#all_check_box', (event) ->
#     $('#proc_div').hide()
#     all_check_click_status = $(this).prop('checked')
#     $('.object_check').prop('checked', all_check_click_status)
#
#     menu_button_update()
#
#     true
#
#   last_click_id = null
#   last_click_status = ""
#
#   $(document).on 'click', '.object_check', (event) ->
#     $('#proc_div').hide()
#     current_click_id = parseInt($(this).attr('id').replace(/checkbox_/, ''))
#     current_click_status = $(this).prop('checked')
#
#     if last_click_id && event.shiftKey && current_click_status == last_click_status
#       for id in [last_click_id..current_click_id]
#         $('#checkbox_' + id).prop('checked', current_click_status)
#
#     menu_button_update()
#
#     last_click_id = current_click_id
#     last_click_status = current_click_status
#
#     true
#
#   $(document).on 'click', '.object_file', ->
#     window.location.href = '/f/' + $(this).data('file-object-id-hash')
#
#     true
#
#   $(document).on 'click', '.object_directory', ->
#     $('#proc_div').hide()
#
#     update_parent_directories_list($(this).data('file-object-id-hash'))
#     update_current_files_list($(this).data('file-object-id-hash'))
#
#     true
#
#   $(document).on 'click', '#menu_upload_file_button', ->
#     $('#proc_mode').val('file_upload')
#     $('#proc_button').text('うｐするで')
#
#     $('#upload_file_form').show()
#     $('#new_directory_form').hide()
#     $('#rename_object_form').hide()
#
#     $('#proc_div').show()
#
#     menu_button_update()
#
#     true
#
#   $(document).on 'click', '#menu_new_directory_button', ->
#     $('#proc_mode').val('directory_make')
#     $('#proc_button').text('ディレクトリ作成するで')
#
#     $('#upload_file_form').hide()
#     $('#new_directory_form').show()
#     $('#rename_object_form').hide()
#
#     $('#proc_div').show()
#
#     $('#new_directory_name').focus()
#
#     menu_button_update()
#
#     true
#
#   $(document).on 'keypress', '#new_directory_name', (event) ->
#     if event.keyCode == 13
#       $('#proc_button').trigger('click')
#
#     true
#
#   $(document).on 'click', '#menu_rename_file_object_button', ->
#     $('#proc_mode').val('object_rename')
#     $('#proc_button').text('リネームするで')
#
#     $('#upload_file_form').hide()
#     $('#new_directory_form').hide()
#     $('#rename_object_form').show()
#
#     $('#all_check_box').attr('checked', false)
#     $('input:checked:not(:first)').attr('checked', false)
#     $('#rename_object_name').val($('input:checked ~ span').text())
#     $('#rename_object_id_hash').val($('input:checked').val())
#
#     $('#proc_div').show()
#
#     $('#rename_object_name').focus()
#
#     true
#
#   $(document).on 'keypress', '#rename_object_name', (event) ->
#     if event.keyCode == 13
#       $('#proc_button').trigger('click')
#
#     true
#
#   $(document).on 'click', '#menu_cut_file_object_button', ->
#     $('#proc_div').hide()
#     $('#proc_mode').val('object_cut')
#     $('#checked_object_id_hashes').val(get_checked_object_id_hashes())
#
#     menu_button_update()
#
#     true
#
#   $(document).on 'click', '#menu_paste_file_object_button', ->
#     $('#proc_div').hide()
#     $('#proc_mode').val('object_paste')
#     $('img#spinner').show()
#     $('#proc_form').ajaxSubmit
#       success: (response) ->
#         $('#checked_object_id_hashes').val('')
#         update_current_files_list($('#current_directory_id_hash').val())
#
#     true
#
#   $(document).on 'click', '#menu_delete_file_object_button', ->
#     if window.confirm('( ｰ`дｰ´)本当にいいんだな？')
#       $('#proc_div').hide()
#       $('#proc_mode').val('object_delete')
#       $('#checked_object_id_hashes').val(get_checked_object_id_hashes())
#       $('img#spinner').show()
#       $('#proc_form').ajaxSubmit
#         success: (response) ->
#           update_current_files_list($('#current_directory_id_hash').val())
#
#     true
#
#   $(document).on 'click', '#proc_button', ->
#     $('#proc_div').hide()
#     $('img#spinner').show()
#     $('#proc_form').ajaxSubmit
#       success: (response) ->
#         $('#new_directory_name').val('')
#         $('#rename_object_name').val('')
#         # upload_filesをクリアする技 もっとシンプルにならないかな？
#         $('#upload_files').after( $('#upload_files').clone(true) )
#         $('#upload_files:first-child').remove()
#         update_current_files_list($('#current_directory_id_hash').val())
#
#     true
#
#   $(document).on 'click', '#menu_edit_user_data_button', ->
#     window.location.href = '/users'
#
#     true
#
#   $(document).on 'click', '#menu_new_user_data_button', ->
#     window.location.href = '/users/new'
#
#     true
#
#   update_parent_directories_list('root')
#   update_current_files_list('root')
