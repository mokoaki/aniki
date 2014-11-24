class FileObject < ActiveRecord::Base
  validates :name,                 presence: true, length: { in: (1..255) }
  validates :parent_directory_id,  presence: true
  validates :id_hash,              presence: true
  validates :object_mode,          inclusion: [1, 2, 3, 4]

  validate do
    if !is_root? && parent_directory_id == 0
      errors.add(:parent_directory_id, 'Can use the "parent_directory_id: 0" only root-directory')
    end

    if is_root? && parent_directory_id != 0
      errors.add(:parent_directory_id, 'Can use the root-directory only "parent_directory_id: 0"')
    end
  end

  belongs_to :parent_directory, class_name: :FileObject, foreign_key: :parent_directory_id
  has_many   :children,         class_name: :FileObject, foreign_key: :parent_directory_id, dependent: :destroy

  default_scope -> { order(:object_mode, :name) }

  before_destroy do
    if is_root? || is_trash?
      false
    else
      if is_file? && FileObject.where(file_hash: file_hash).count == 1
        FileUtils.rm(file_fullpath)
      end
    end
  end

  before_save do
    self.name ||= ''
    self.name.scrub!(' ')
    self.name.gsub!("\n", ' ')
    self.name.gsub!("\t", ' ')
    self.name.gsub!("\\", ' ')
    self.name.gsub!('　', ' ')
    self.name.gsub!(/ +/, ' ')
    self.name.strip!
    self.name.gsub!('"', '”')
    self.name.gsub!("'", '’')
    self.name.gsub!('<', '＜')
    self.name.gsub!('>', '＞')
    self.name.gsub!('*', '＊')
    self.name.gsub!(':', '：')
    self.name.gsub!(';', '；')
    self.name.gsub!('?', '？')
    self.name.gsub!('|', '｜')
    self.name.gsub!('/', '／')
  end

  class << self
    def get_directory_object_by_id_hash(id_hash)
      find_by(id_hash: id_hash, object_mode: [1, 2, 3])
    end

    def get_file_or_directory_object_by_id_hash(id_hash)
      find_by(id_hash: id_hash, object_mode: [3, 4])
    end

    def get_file_or_directory_object_by_id_hashes(id_hashes)
      where(id_hash: id_hashes, object_mode: [3, 4])
    end

    def get_trash_object
      find_by(object_mode: 2)
    end
  end

  def file_upload(upload_file)
    file_data = upload_file.read

    new_file_object               = children.new
    new_file_object[:name]        = upload_file.original_filename
    new_file_object[:object_mode] = 4
    new_file_object[:id_hash]     = Digest::SHA1.hexdigest("#{Time.now}#{new_file_object[:name]}")
    new_file_object[:file_hash]   = Digest::SHA1.hexdigest(file_data)
    new_file_object[:size]        = upload_file.size

    FileUtils.mkdir_p new_file_object.file_save_path

    File.open(new_file_object.file_fullpath, 'wb') do |fo|
      fo.write(file_data)
    end

    new_file_object.save

    touch
  end

  def directory_make(new_directory_name)
    new_directory_object               = children.new
    new_directory_object[:name]        = new_directory_name
    new_directory_object[:object_mode] = 3
    new_directory_object[:id_hash]     = Digest::SHA1.hexdigest("#{Time.now}#{new_directory_name}")
    new_directory_object.save

    touch
  end

  def object_rename(rename_object_name)
    update_attributes(name: rename_object_name)
    parent_directory.touch
  end

  def object_paste(current_directory_id_hash)
    current_directory_object  = FileObject.get_directory_object_by_id_hash(current_directory_id_hash)

    update_attributes(parent_directory_id: current_directory_object[:id])
    current_directory_object.touch
  end

  def object_delete
    return if is_root? || is_trash?

    if is_trash_ancestor?
      destroy
    else
      trash_object = FileObject.get_trash_object
      update_attributes(parent_directory_id: trash_object[:id])
    end
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

  def updated_at_h
    updated_at.strftime("%Y/%m/%d %T")
  end

  def file_fullpath
    File.join(file_save_path, file_hash)
  end

  def get_parent_directories_list
    (is_root? ? [] : parent_directory.get_parent_directories_list) + [{ id_hash: id_hash, name: name }]
  end

  def file_save_path
    File.join(Rails.application.secrets.data_path, file_hash[0, 2])
  end

  def is_trash_ancestor?
    return false if is_root?
    return true  if is_trash?

    parent_directory.is_trash_ancestor?
  end
end
