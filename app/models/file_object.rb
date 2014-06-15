class FileObject < ActiveRecord::Base
  def directory_save(params)
    self.name                = params[:name]
    self.parent_directory_id = params[:parent_directory_id]
    self.object_mode         = 2
    self.save
  end

  def file_save(upload_file, parent_directory_id)
    self.name                = upload_file.original_filename
    self.parent_directory_id = parent_directory_id
    self.object_mode         = 3
    self.hash_name           = SecureRandom.hex(32)
    self.size                = upload_file.size

    FileUtils.mkdir_p file_save_path

    File.open(file_save_path + self.hash_name, 'wb') do |fo|
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

  #class_method

  def self.get_parent_directories(directory_id)
    if directory_id.to_i == 0
      return [{id: 0, name: 'root'}]
    end

    file_object = FileObject.find_by(id: directory_id, object_mode: 2)

    [{id: file_object.id, name: file_object.name}] + get_parent_directories(file_object.parent_directory_id)
  end

  private

  def file_save_path
    Rails.application.secrets.data_path + hash_name[0, 2] + '/'
  end
end
