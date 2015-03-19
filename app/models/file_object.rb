class FileObject < ActiveRecord::Base
  validates :name,                     presence: true, length: { in: (1..255) }
  validates :id_hash,                  presence: true
  validates :object_mode,              inclusion: [1, 2, 3, 4]

  validates :parent_directory_id_hash, inclusion: { in: [''] }, if: 'is_root?'
  validates :parent_directory_id_hash, presence: true, if: '!is_root?'

  validate do
    if !is_root?
      if parent_directory_id_hash.present?
        parent_directory_object = FileObject.get_directory_object_by_id_hash(parent_directory_id_hash)

        if parent_directory_object.nil?
          errors.add(:parent_directory_id_hash, 'Not found parent object')
        else
          if is_mine_ancestor?
            errors.add(:parent_directory_id_hash, '自分の子孫の子供になってはいけない！')
          end
        end
      end
    end
  end

  # enum object_mode [:root, :gomibako, :directory, :file]

  belongs_to :parent_directory, class_name: :FileObject, primary_key: :id_hash, foreign_key: :parent_directory_id_hash
  has_many   :children,         class_name: :FileObject, primary_key: :id_hash, foreign_key: :parent_directory_id_hash, dependent: :destroy


  # enum object_mode: {root_object: 1, trash_object: 2, directory_object: 3, file_object: 4}
  # enum object_mode: [:root_object, :trash_object, :directory_object, :file_object]
  # enum object_mode: ['root_object', 'trash_object', 'directory_object', 'file_object']

  # default_scope -> { order(:object_mode, :name) }

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
    def get_trash_object
      find_by(object_mode: 2)
    end

    def get_children_by_id_hash(id_hash)
      where({parent_directory_id_hash: id_hash})
    end

    def get_directory_object_by_id_hash(id_hash)
      find_by(id_hash: id_hash, object_mode: [1, 2, 3])
    end

    def get_file_or_directory_object_by_id_hash(id_hash)
      find_by(id_hash: id_hash, object_mode: [3, 4])
    end

    def get_file_object_by_id_hash(id_hash)
      find_by(id_hash: id_hash, object_mode: 4)
    end

    def create_directory(params)
      file_object                            = FileObject.new
      file_object[:name]                     = params[:name]
      file_object[:parent_directory_id_hash] = params[:parent_directory_id_hash]
      file_object[:object_mode]              = 3
      file_object[:id_hash]                  = FileObject.get_random_sha1

      file_object.save

      return file_object
    end

    def upload_file(params)
      file      = params[:file]
      file_data = file.read

      file_object                            = FileObject.new
      file_object[:name]                     = file.original_filename
      file_object[:parent_directory_id_hash] = params[:parent_directory_id_hash]
      file_object[:object_mode]              = 4
      file_object[:id_hash]                  = FileObject.get_random_sha1
      file_object[:file_hash]                = Digest::SHA1.hexdigest(file_data)
      file_object[:size]                     = file.size

      if File.exist?(file_object.file_fullpath) == false
        FileUtils.mkdir_p file_object.file_save_path

        File.open(file_object.file_fullpath, 'wb') do |fo|
          fo.write(file_data)
        end
      end

      file_object.save

      return file_object
    end

    def get_random_sha1
      return Digest::SHA1.hexdigest(Time.now.to_s + SecureRandom.urlsafe_base64)
    end
  end

  def object_delete
    return if is_root? || is_trash?

    if is_trash_ancestor?
      destroy
    else
      trash_object = FileObject.get_trash_object
      update_attributes(parent_directory_id_hash: trash_object[:id_hash])
    end

    return self
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
    File.join(file_save_path, self.file_hash)
  end

  def get_parent_directories_list
    (is_root? ? [] : parent_directory.get_parent_directories_list) + [{ id_hash: self.id_hash, name: self.name }]
  end

  def file_save_path
    File.join(Rails.application.secrets.data_path, self.file_hash[0, 2])
  end

  def is_trash_ancestor?
    return false if is_root?
    return true  if is_trash?

    parent_directory.is_trash_ancestor?
  end

  # 自分の祖先に自分が居るような状況はありえない
  def is_mine_ancestor?
    ancestors = FileObject.get_directory_object_by_id_hash(parent_directory_id_hash).get_parent_directories_list

    ancestors.each do |ancestor|
      return true if ancestor[:id_hash] == id_hash
    end

    return false
  end
end
