require 'rails_helper'

describe FileObject do
  before { @file_object = FactoryGirl.build(:file_object) }

  context 'methods' do
    it 'columns' do
      expect(@file_object).to respond_to(:name)
      expect(@file_object).to respond_to(:parent_directory_id)
      expect(@file_object).to respond_to(:object_mode)
      expect(@file_object).to respond_to(:hash_name)
      expect(@file_object).to respond_to(:size)
      expect(@file_object).to respond_to(:created_at)
    end

    it 'public methods' do
      expect(@file_object).to respond_to(:file_save)
      expect(@file_object).to respond_to(:is_root?)
      expect(@file_object).to respond_to(:is_directory?)
      expect(@file_object).to respond_to(:is_file?)
      expect(@file_object).to respond_to(:created_at_h)
      expect(@file_object).to respond_to(:file_fullpath)
      expect(@file_object).to respond_to(:get_parent_directories_list)
      expect(@file_object).to respond_to(:ancestor_trash?)
      expect(@file_object).to respond_to(:go_to_bed)
    end

    it 'relations' do
      expect(@file_object).to respond_to(:parent_directory)
      expect(@file_object).to respond_to(:children)
    end

    it 'class methods' do
      expect(FileObject).to respond_to(:get_directory_by_id)
      expect(FileObject).to respond_to(:get_trash_object)
      expect(FileObject).to respond_to(:get_digest)
      expect(FileObject).to respond_to(:check_digest)
      expect(FileObject).to respond_to(:check_digests)
    end

    it 'privete methods' do
      expect(@file_object.respond_to?(:file_save_path, true)).to be_truthy
      expect(@file_object.respond_to?(:go_to_trash, true)).to be_truthy
    end
  end

  describe 'validation' do
    context 'name' do
      it 'nil invalid' do
        @file_object.name = nil
        expect(@file_object).to be_invalid
      end

      it 'null_character invalid' do
        @file_object.name = ''
        expect(@file_object).to be_invalid
      end

      it 'space invalid' do
        @file_object.name = ' '
        expect(@file_object).to be_invalid
      end

      it 'A valid' do
        @file_object.name = 'A'
        expect(@file_object).to be_valid
      end

      it 'A * 255 valid' do
        @file_object.name = 'A' * 255
        expect(@file_object).to be_valid
      end

      it 'A * 256 invalid' do
        @file_object.name = 'A' * 256
        expect(@file_object).to be_invalid
      end

      it 'あ * 255 valid' do
        @file_object.name = 'あ' * 255
        expect(@file_object).to be_valid
      end

      it 'あ * 256 invalid' do
        @file_object.name = 'あ' * 256
        expect(@file_object).to be_invalid
      end
    end

    context 'parent_directory_id' do
      it 'nil invalid' do
        @file_object.parent_directory_id = nil
        expect(@file_object).to be_invalid
      end

      it 'null_character invalid' do
        @file_object.parent_directory_id = ''
        expect(@file_object).to be_invalid
      end

      it 'space invalid' do
        @file_object.parent_directory_id = ' '
        expect(@file_object).to be_invalid
      end

      it 'A invalid' do
        @file_object.parent_directory_id = 'A'
        expect(@file_object).to be_invalid
      end

      it 'parent_directory_id:0 and object_mode:4 invalid' do
        @file_object.parent_directory_id = 0
        expect(@file_object).to be_invalid
      end

      it 'parent_directory_id:0 and object_mode:1 valid' do
        @file_object.parent_directory_id = 0
        @file_object.object_mode = 1
        expect(@file_object).to be_valid
      end

      it '1 valid' do
        @file_object.parent_directory_id = 1
        expect(@file_object).to be_valid
      end
    end

    context 'object_mode' do
      it 'nil invalid' do
        @file_object.object_mode = nil
        expect(@file_object).to be_invalid
      end

      it 'null_character invalid' do
        @file_object.object_mode = ''
        expect(@file_object).to be_invalid
      end

      it 'space invalid' do
        @file_object.object_mode = ' '
        expect(@file_object).to be_invalid
      end

      it 'A invalid' do
        @file_object.object_mode = 'A'
        expect(@file_object).to be_invalid
      end

      it '0 invalid' do
        @file_object.object_mode = 0
        expect(@file_object).to be_invalid
      end

      it '1 valid' do
        @file_object.object_mode = 1
        expect(@file_object).to be_valid
      end

      it '4 valid' do
        @file_object.object_mode = 4
        expect(@file_object).to be_valid
      end

      it '5 invalid' do
        @file_object.object_mode = 5
        expect(@file_object).to be_invalid
      end
    end
  end

  describe 'relations' do
    it 'parent_directory' do
      root_object = FactoryGirl.create(:root_object)
      @file_object.parent_directory_id = root_object.id

      expect(@file_object.parent_directory).to eq(root_object)
    end

    it 'children' do
      root_object      = FactoryGirl.create(:root_object)
      directory_object = FactoryGirl.create(:directory_object, parent_directory_id: root_object.id)
      @file_object.parent_directory_id = root_object.id
      @file_object.save

      expect(root_object.children.to_a).to eq([directory_object, @file_object])
    end
  end

  it 'default_scope' do
    expect(FileObject.all.to_sql).to eq(FileObject.unscoped.order(:object_mode, :name).to_sql)
  end

  describe 'event' do
    it 'delete file' do
      @file_object.hash_name = 'zz'
      FileUtils.mkdir_p Rails.application.secrets.data_path + 'zz'
      FileUtils.touch Rails.application.secrets.data_path + 'zz/zz'
      @file_object.destroy

      expect(FileTest.exist?(Rails.application.secrets.data_path + 'zz/zz')).to be_falsy
      expect(FileTest.exist?(Rails.application.secrets.data_path + 'zz')).to be_falsy
      expect(@file_object.destroyed?).to be_truthy
    end

    it 'before_save' do
      @file_object.name = "\n\t\\\"<a>'*:;b?|/"
      @file_object.save
      expect(@file_object.name).to eq('”＜a＞’＊：；b？｜／')
    end
  end

  describe 'class methods' do
    context 'get_directory_by_id' do
      it 'if directory' do
        directory_object = FactoryGirl.create(:directory_object)
        expect(FileObject.get_directory_by_id(directory_object.id)).to eq(directory_object)
      end

      it 'if file' do
        expect(FileObject.get_directory_by_id(@file_object.id)).to eq(nil)
      end
    end

    it 'get_trash_object' do
      expect(FileObject.get_trash_object).to eq(FileObject.find_by(object_mode: 2))
    end

    it 'get_digest' do
      id = 9999

      expect(FileObject.get_digest(id)).to eq(Digest::SHA2.hexdigest(Rails.application.secrets.salt + id.to_i.to_s))
    end

    context 'check_digest' do
      it '正常' do
        id = '9999'
        digest = Digest::SHA2.hexdigest(Rails.application.secrets.salt + id.to_i.to_s)

        expect(FileObject.check_digest(id, digest)).to eq(id)
      end

      it '不正' do
        id = '9999'
        digest = ''

        expect(FileObject.check_digest(id, digest)).to eq(nil)
      end
    end

    it 'check_digests' do
      id1 = '1'
      id2 = '2'
      id3 = '3'
      digest1 = Digest::SHA2.hexdigest(Rails.application.secrets.salt + id1.to_i.to_s)
      digest2 = ''
      digest3 = Digest::SHA2.hexdigest(Rails.application.secrets.salt + id3.to_i.to_s)
      data = {
              'hoge1' => { 'id' => id1, 'id_digest' => digest1 },
              'hoge2' => { 'id' => id2, 'id_digest' => digest2 },
              'hoge3' => { 'id' => id3, 'id_digest' => digest3 }
             }

      expect(FileObject.check_digests(data)).to eq(['1', '3'])
    end
  end

  describe 'public methods' do
    it 'file_save' do
      root_object = FactoryGirl.create(:root_object)
      child_object = root_object.children.new
      child_object.file_save(nil, 'zy')

      expect(child_object.persisted?).to be_truthy
      expect(FileTest.exist?(Rails.application.secrets.data_path + 'zy/zy')).to be_truthy

      child_object.destroy
    end

    context 'is_root?' do
      it 'rootの場合はtrue それ以外はfalse' do
        root_object      = FactoryGirl.build(:root_object)
        trash_object     = FactoryGirl.build(:trash_object)
        directory_object = FactoryGirl.build(:directory_object)

        expect(root_object.is_root?).to be_truthy
        expect(trash_object.is_root?).to be_falsy
        expect(directory_object.is_root?).to be_falsy
        expect(@file_object.is_root?).to be_falsy
      end
    end

    context 'is_trash?' do
      it 'ゴミ箱の場合はtrue それ以外はfalse' do
        root_object      = FactoryGirl.build(:root_object)
        trash_object     = FactoryGirl.build(:trash_object)
        directory_object = FactoryGirl.build(:directory_object)

        expect(root_object.is_trash?).to be_falsy
        expect(trash_object.is_trash?).to be_truthy
        expect(directory_object.is_trash?).to be_falsy
        expect(@file_object.is_trash?).to be_falsy
      end
    end

    context 'is_directory?' do
      it 'ディレクトリの場合はtrue それ以外はfalse' do
        root_object      = FactoryGirl.build(:root_object)
        trash_object     = FactoryGirl.build(:trash_object)
        directory_object = FactoryGirl.build(:directory_object)

        expect(root_object.is_directory?).to be_falsy
        expect(trash_object.is_directory?).to be_falsy
        expect(directory_object.is_directory?).to be_truthy
        expect(@file_object.is_directory?).to be_falsy
      end
    end

    context 'is_file?' do
      it 'ファイルの場合はtrue それ以外はfalse' do
        root_object      = FactoryGirl.build(:root_object)
        trash_object     = FactoryGirl.build(:trash_object)
        directory_object = FactoryGirl.build(:directory_object)

        expect(root_object.is_file?).to be_falsy
        expect(trash_object.is_file?).to be_falsy
        expect(directory_object.is_file?).to be_falsy
        expect(@file_object.is_file?).to be_truthy
      end
    end

    it 'created_at_h' do
      @file_object.save
      expect(@file_object.created_at_h).to eq(@file_object.created_at.strftime("%Y/%m/%d %T"))
    end

    it 'file_fullpath' do
      @file_object.hash_name = 'zz'
      expect(@file_object.file_fullpath).to eq(Rails.application.secrets.data_path + 'zz/zz')
    end

    context 'get_parent_directories_list' do
      it 'root' do
        root_object = FactoryGirl.create(:root_object)
        @file_object.parent_directory_id = root_object.id
        @file_object.save

        expect(@file_object.get_parent_directories_list).to eq( [{ name: @file_object.name, id: @file_object.id }, { name: root_object.name, id: root_object.id }] )
      end

      it 'trash' do
        root_object = FactoryGirl.create(:root_object)
        trash_object = FactoryGirl.create(:trash_object, parent_directory_id: root_object.id)
        trash_file_object = FactoryGirl.create(:trash_file_object, parent_directory_id: trash_object.id)

        expect(trash_file_object.get_parent_directories_list).to eq( [{ name: trash_file_object.name, id: trash_file_object.id }, { name: trash_object.name, id: trash_object.id }, { name: root_object.name, id: root_object.id }] )
      end
    end

    context 'ancestor_trash?' do
      it 'ゴミ箱内ならtrue' do
        trash_object = FactoryGirl.create(:trash_object)
        trash_file_object = FactoryGirl.build(:trash_file_object, parent_directory_id: trash_object.id)

        expect(trash_file_object.ancestor_trash?).to be_truthy
      end

      it 'root配下ならfalse' do
        root_object = FactoryGirl.create(:root_object)
        @file_object.parent_directory_id = root_object.id

        expect(@file_object.ancestor_trash?).to be_falsy
      end
    end

    context 'go_to_bed' do
      it 'rootならfalse' do
        root_object = FactoryGirl.build(:root_object)
        expect(root_object.go_to_bed).to be_falsy
      end

      it 'ゴミ箱ならfalse' do
        trash_object = FactoryGirl.build(:trash_object)
        expect(trash_object.go_to_bed).to be_falsy
      end

      it 'ゴミ箱内なら 削除される' do
        trash_object      = FactoryGirl.create(:trash_object)
        trash_file_object = FactoryGirl.create(:trash_file_object, parent_directory_id: trash_object.id)
        trash_file_object.go_to_bed

        expect(trash_file_object.destroyed?).to be_truthy
      end

      it 'root配下ならparent_directory_idがゴミ箱.idに変わる' do
        root_object = FactoryGirl.create(:root_object)
        trash_object = FactoryGirl.create(:trash_object)
        @file_object.parent_directory_id = root_object.id
        @file_object.go_to_bed

        expect(@file_object.parent_directory_id).to eq(trash_object.id)
      end
    end
  end

  describe 'private methods' do
    it 'file_save_path' do
      @file_object.hash_name = 'zz'
      expect(@file_object.send(:file_save_path)).to eq(Rails.application.secrets.data_path + 'zz/')
    end

    it 'go_to_trash' do
      trash_object = FactoryGirl.create(:trash_object)
      @file_object.send(:go_to_trash)

      expect(@file_object.parent_directory_id).to eq(trash_object.id)
    end
  end
end
