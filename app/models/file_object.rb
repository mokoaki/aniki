class FileObject < ActiveRecord::Base
  validates :name, presence: true
  validates :parent_directory_id, presence: true
  validates :object_mode,         presence: true

  belongs_to :parent_directory, class_name: :FileObject, foreign_key: :parent_directory_id
  has_many   :children,         class_name: :FileObject, foreign_key: :parent_directory_id, dependent: :destroy

  default_scope -> { order(:object_mode, :name) }

  before_destroy do
    if is_file?
      FileUtils.rm(file_fullpath) rescue nil
      FileUtils.rmdir(file_save_path) rescue nil
    end
  end

  class << self
    def get_directory_by_id(directory_id)
      find_by(id: directory_id, object_mode: [1, 2, 3])
    end

    def get_digest(id)
      Digest::SHA2.hexdigest(Rails.application.secrets.salt + id.to_i.to_s)
    end

    def check_digest(id, digest)
      digest == get_digest(id) ? id : nil
    end
  end

  def file_save(upload_file)
    self.name                = upload_file.original_filename
    self.object_mode         = 4
    self.hash_name           = SecureRandom.hex(32)
    self.size                = upload_file.size

    FileUtils.mkdir_p file_save_path

    File.open(file_fullpath, 'wb') do |fo|
      fo.write(upload_file.read)
    end

    save
  end

  def is_root?
    object_mode == 1
  end

  def is_trash?
    object_mode == 2
  end

  def is_directory?
    object_mode == 3
  end

  def is_file?
    object_mode == 4
  end

  def created_at_h
    created_at.strftime("%Y/%m/%d %T")
  end

  def file_fullpath
    file_save_path + hash_name
  end

  def get_parent_directories
    [{id: id, name: name}] + (parent_directory_id == 0 ? [] : FileObject.get_directory_by_id(parent_directory_id).get_parent_directories)
  end

  #遡るとゴミ箱内かどうか？
  def ancestor_trash?
    case true
    when is_root?
      return false
    when is_trash?
      return true
    end

    parent_directory.ancestor_trash?
  end

  def goto_trash
    self.parent_directory_id = 2
    save
  end

  def go_to_bed
    if is_root? || is_trash?
      return
    elsif ancestor_trash?
      destroy
    else
      goto_trash
    end
  end

  private

  def file_save_path
    Rails.application.secrets.data_path + hash_name[0, 2] + '/'
  end
end
