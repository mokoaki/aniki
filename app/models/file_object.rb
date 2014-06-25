class FileObject < ActiveRecord::Base
  validates :name, presence: true, length: { in: (1..255) }
  validates :parent_directory_id,  presence: true
  validates :object_mode,          inclusion: [1, 2, 3, 4]

  validate do
    if !is_root? && parent_directory_id == 0
      errors.add(:parent_directory_id, 'use 0 only root directory')
    end
  end

  belongs_to :parent_directory, class_name: :FileObject, foreign_key: :parent_directory_id
  has_many   :children,         class_name: :FileObject, foreign_key: :parent_directory_id, dependent: :destroy

  default_scope -> { order(:object_mode, :name) }

  before_destroy do
    if is_file?
      FileUtils.rm(file_fullpath) rescue true
      FileUtils.rmdir(file_save_path) rescue true
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
    def get_directory_by_id(directory_id)
      find_by(id: directory_id, object_mode: [1, 2, 3])
    end

    def get_trash_object
      FileObject.find_by(object_mode: 2)
    end

    def get_digest(id)
      Digest::SHA2.hexdigest(Rails.application.secrets.salt + id.to_i.to_s)
    end

    def check_digest(id, digest)
      digest == get_digest(id) ? id : nil
    end

    def check_digests(data)
      result = []

      data.each_value do |value|
        if check_digest(value['id'], value['id_digest'])
          result << value['id']
        end
      end

      result.uniq
    end
  end

  def file_save(upload_file, test_hash = nil)
    self.name                = test_hash ? 'test' : upload_file.original_filename
    self.object_mode         = 4
    self.hash_name           = test_hash || SecureRandom.hex(32)
    self.size                = test_hash ? 0 : upload_file.size

    FileUtils.mkdir_p file_save_path

    File.open(file_fullpath, 'wb') do |fo|
      fo.write(test_hash ? '' : upload_file.read)
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

  def get_parent_directories_list
    [{ id: id, name: name }] + (is_root? ? [] : parent_directory.get_parent_directories_list)
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

  def go_to_bed
    if is_root? || is_trash?
      return false
    elsif ancestor_trash?
      destroy
    else
      go_to_trash
    end
  end

  private

  def file_save_path
    Rails.application.secrets.data_path + hash_name[0, 2] + '/'
  end

  def go_to_trash
    self.parent_directory_id = FileObject.get_trash_object.id
    save
  end
end
