module FileObjectsHelper
  def get_icon_image(file_object)
    case true
    when file_object.is_trash?
      image_tag('icon_trash_alt.png')
    when file_object.is_directory?
      image_tag('icon_folder_alt.png')
    else
      image_tag('icon_document_alt.png')
    end
  end

  def get_check_box(file_object)
    #ゴミ箱はチェックさせない
    check_box_tag("file_object_checks_#{file_object.id}", file_object.id, false, 'data-check_id_digest' => FileObject.get_digest(file_object.id), disabled: file_object.is_trash?, class: :file_object_checks, onchange: 'file_object_checkeds_check()')
  end
end
