module FileObjectHelper
  def write_parent_directories(parent_directories)
    count = 0
    result = []

    @parent_directories.reverse_each do |parent_directory|
      result << %Q(<div style="margin-left:#{count * 20}px;">)
      result << (count > 0 ? '└' : ' ')
      result << link_to_unless_current(parent_directory[:name], directory_path(parent_directory[:id]))
      result << '</div>'

      count += 1
    end

    result.join.html_safe
  end

  def get_icon_image(file_object)
    case true
      when file_object.is_trash?
        image_tag('icon_trash_alt.png')
      when file_object.is_directory?
        image_tag('icon_folder_alt.png')
      else
        image_tag('icon_document_alt.png')
      end
    #end
  end

  def get_object_line(file_object)
    if file_object.is_file?
      "#{file_object.name} [#{file_object.size}Byte] [#{file_object.created_at_h}] [#{file_object.updated_at_h}]"
    else
      link_to file_object.name, directory_path(file_object.id)
    end
  end
end
