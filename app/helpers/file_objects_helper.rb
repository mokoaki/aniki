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

  def get_check_box(file_object, index)
    if file_object.is_trash?
      check_box_tag(nil, nil, false, {class: :no_check, disabled: true})
    else
      check_box_tag("checkbox_#{index + 1}", file_object[:id_hash], false, {class: :object_check})
    end
  end
  #
  # def size_h(size)
  #   size = size.to_f
  #
  #   moko = case true
  #   when size < 1.kilobyte
  #     [size, 'B']
  #   when size < 1.megabyte
  #     [size / 1.kilobyte, 'KB']
  #   when size < 1.gigabyte
  #     [size / 1.megabyte, 'MB']
  #   else
  #     [size / 1.gigabyte, 'GB']
  #   end
  #
  #   "#{moko[0].round(2)} #{moko[1]}"
  # end
end
