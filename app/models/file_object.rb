class FileObject < ActiveRecord::Base
  def file_save(upload_file, parent_directory_id)
    self.name                = upload_file.original_filename
    self.parent_directory_id = parent_directory_id
    self.object_mode         = 3
    self.hash_name           = SecureRandom.hex(32)
    self.size                = upload_file.size

    FileUtils.mkdir_p file_save_path

    File.open(file_fullpath, 'wb') do |fo|
      fo.write(upload_file.read)
    end

    self.save
  end

  def is_trash?
    object_mode == 1
  end

  def is_directory?
    object_mode == 2
  end

  def is_file?
    object_mode == 3
  end

  def created_at_h
    created_at.strftime("%Y/%m/%d %T")
  end

  def updated_at_h
    updated_at.strftime("%Y/%m/%d %T")
  end

  def file_fullpath
    file_save_path + hash_name
  end

  def go_to_bed
    if is_trash?
      #ゴミ箱は対象外　通常はこの処理は動かないが、万が一の為の処理
      return
    end

####################
現在、ゴミ箱直下以外はゴミ箱直下に移動してしまう
　　ROOTーゴミ箱-dir-dir
                    ↑こいつは削除されずにゴミ箱直下に移動してしまう
                それを考える　俺は寝る 

    if parent_directory_id != 1
      #ゴミ箱以外は一旦ゴミ箱に入れる
      self.parent_directory_id = 1
      save
    else
      if is_file?
        FileUtils.rm(file_fullpath)
      end

      if is_directory?
        child_file_objects = FileObject.where(parent_directory_id: id)

        child_file_objects.each do |child_file_object|
          child_file_object.go_to_bed
        end
      end

      destroy
    end
  end

  #class_method

  def self.get_parent_directories(directory_id)
    if directory_id.to_i == 0
      return [{id: 0, name: 'root'}]
    end

    file_object = FileObject.find_by(id: directory_id, object_mode: [1, 2])

    [{id: file_object.id, name: file_object.name}] + get_parent_directories(file_object.parent_directory_id)
  end

  private

  def file_save_path
    Rails.application.secrets.data_path + hash_name[0, 2] + '/'
  end
end
