require 'rails_helper'

describe FileObject do
  let(:file_object) { FactoryGirl.build(:file_object) }
  let(:data_path)   { Rails.application.secrets.data_path }
  let(:id_hash)     { SecureRandom.hex[0, 40] }

  context 'check methods' do
    it 'columns' do
      expect(file_object).to respond_to(:name)
      expect(file_object).to respond_to(:parent_directory_id)
      expect(file_object).to respond_to(:object_mode)
      expect(file_object).to respond_to(:id_hash)
      expect(file_object).to respond_to(:file_hash)
      expect(file_object).to respond_to(:size)
      expect(file_object).to respond_to(:created_at)
      expect(file_object).to respond_to(:updated_at)
    end

    it 'class methods' do
      expect(FileObject).to respond_to(:get_directory_object_by_id_hash)
      expect(FileObject).to respond_to(:get_file_or_directory_object_by_id_hash)
      expect(FileObject).to respond_to(:get_file_or_directory_object_by_id_hashes)
      expect(FileObject).to respond_to(:get_trash_object)
    end

    it 'instance methods' do
      expect(file_object).to respond_to(:file_upload)
      expect(file_object).to respond_to(:directory_make)
      expect(file_object).to respond_to(:object_rename)
      expect(file_object).to respond_to(:object_paste)
      expect(file_object).to respond_to(:object_delete)
      expect(file_object).to respond_to(:is_root?)
      expect(file_object).to respond_to(:is_trash?)
      expect(file_object).to respond_to(:is_directory?)
      expect(file_object).to respond_to(:is_file?)
      expect(file_object).to respond_to(:updated_at_h)
      expect(file_object).to respond_to(:file_fullpath)
      expect(file_object).to respond_to(:get_parent_directories_list)
      expect(file_object).to respond_to(:file_save_path)
      expect(file_object).to respond_to(:is_trash_ancestor?)
    end

    it 'relations' do
      expect(file_object).to respond_to(:parent_directory)
      expect(file_object).to respond_to(:children)
    end
  end

  describe 'validation' do
    context 'name' do
      it 'nil invalid' do
        file_object[:name] = nil
        expect(file_object).to be_invalid
      end

      it 'null_character invalid' do
        file_object[:name] = ''
        expect(file_object).to be_invalid
      end

      it 'space invalid' do
        file_object[:name] = ' '
        expect(file_object).to be_invalid
      end

      it 'A valid' do
        file_object[:name] = 'A'
        expect(file_object).to be_valid
      end

      it 'A * 255 valid' do
        file_object[:name] = 'A' * 255
        expect(file_object).to be_valid
      end

      it 'A * 256 invalid' do
        file_object[:name] = 'A' * 256
        expect(file_object).to be_invalid
      end

      it 'あ * 255 valid' do
        file_object[:name] = 'あ' * 255
        expect(file_object).to be_valid
      end

      it 'あ * 256 invalid' do
        file_object[:name] = 'あ' * 256
        expect(file_object).to be_invalid
      end
    end

    context 'parent_directory_id' do
      it 'nil invalid' do
        file_object[:parent_directory_id] = nil
        expect(file_object).to be_invalid
      end

      it 'null_character invalid' do
        file_object[:parent_directory_id] = ''
        expect(file_object).to be_invalid
      end

      it 'space invalid' do
        file_object[:parent_directory_id] = ' '
        expect(file_object).to be_invalid
      end

      it 'A invalid' do
        file_object[:parent_directory_id] = 'A'
        expect(file_object).to be_invalid
      end

      it 'parent_directory_id:0 and object_mode:4 invalid' do
        file_object[:parent_directory_id] = 0
        file_object[:object_mode] = 4
        expect(file_object).to be_invalid
      end

      it 'parent_directory_id:0 and object_mode:1 valid' do
        file_object[:parent_directory_id] = 0
        file_object[:object_mode] = 1
        expect(file_object).to be_valid
      end

      it 'parent_directory_id:1 and object_mode:4 valid' do
        file_object[:parent_directory_id] = 1
        file_object[:object_mode] = 4
        expect(file_object).to be_valid
      end

      it 'parent_directory_id:1 and object_mode:1 invalid' do
        file_object[:parent_directory_id] = 1
        file_object[:object_mode] = 1
        expect(file_object).to be_invalid
      end
    end

    context 'object_mode' do
      it 'nil invalid' do
        file_object[:object_mode] = nil
        expect(file_object).to be_invalid
      end

      it 'null_character invalid' do
        file_object[:object_mode] = ''
        expect(file_object).to be_invalid
      end

      it 'space invalid' do
        file_object[:object_mode] = ' '
        expect(file_object).to be_invalid
      end

      it 'A invalid' do
        file_object[:object_mode] = 'A'
        expect(file_object).to be_invalid
      end

      it '0 invalid' do
        file_object[:object_mode] = 0
        expect(file_object).to be_invalid
      end

      it 'object_mode == 1 and parent_directory_id == 0 valid' do
        file_object[:object_mode] = 1
        file_object[:parent_directory_id] = 0
        expect(file_object).to be_valid
      end

      it 'object_mode == 1 and parent_directory_id != 0 invalid' do
        file_object[:object_mode] = 1
        file_object[:parent_directory_id] = 1
        expect(file_object).to be_invalid
      end

      it '4 valid' do
        file_object[:object_mode] = 4
        expect(file_object).to be_valid
      end

      it '5 invalid' do
        file_object[:object_mode] = 5
        expect(file_object).to be_invalid
      end
    end
  end

  describe 'relations' do
    before(:each) do
      file_object[:parent_directory_id] = root_object[:id]
      file_object.save
    end

    let(:root_object) { FactoryGirl.create(:root_object) }

    describe 'parent_directory' do
      it 'return root object' do
        expect(file_object.parent_directory).to eq(root_object)
      end
    end

    describe 'children' do
      it 'return file object' do
        expect(root_object.children).to eq([file_object])
      end
    end
  end

  it 'default_scope' do
    expect(FileObject.all.to_sql).to eq(FileObject.unscoped.order(:object_mode, :name).to_sql)
  end

  describe 'event' do
    describe 'before_destroy' do
      context 'root object' do
        before(:each) do
          root_object.destroy
        end

        let(:root_object) { FactoryGirl.build(:root_object) }

        it 'fail destroy' do
          expect(root_object.destroyed?).to be_falsy
        end
      end

      context 'trash object' do
        before(:each) do
          trash_object.destroy
        end

        let(:trash_object) { FactoryGirl.build(:trash_object) }

        it 'fail destroy' do
          expect(trash_object.destroyed?).to be_falsy
        end
      end

      context 'directory object' do
        before(:each) do
          directory_object.destroy
        end

        let(:directory_object) { FactoryGirl.build(:directory_object) }

        it 'sucess destroy' do
          expect(directory_object.destroyed?).to be_truthy
        end
      end

      context 'file object' do
        context 'There are a plurality of FileObject that refer to the same file' do
          before(:each) do
            expect(FileUtils).to receive(:rm).with(file_object.file_fullpath)
            file_object1.destroy
          end

          let(:file_object1) { FactoryGirl.create(:file_object) }
          let!(:file_object2) { FactoryGirl.create(:file_object) }

          it 'sucess destroy' do
            expect(file_object1.destroyed?).to be_truthy
          end
        end

        context 'There is only one FileObject you are referring to the same file' do
          before(:each) do
            expect(FileUtils).to receive(:rm).with(file_object.file_fullpath)
            file_object.save
            file_object.destroy
          end

          it 'sucess destroy' do
            expect(file_object.destroyed?).to be_truthy
          end
        end
      end
    end

    describe 'before_save' do
      before(:each) do
        file_object[:name] = "\n\t\\\"<a>'*:;b?|/"
        file_object.save
      end

      it 'replace string' do
        expect(file_object.name).to eq('”＜a＞’＊：；b？｜／')
      end
    end
  end

  describe 'class methods' do
    describe 'get_directory_object_by_id_hash' do
      context 'root object' do
        let!(:root_object) { FactoryGirl.create(:root_object, id_hash: id_hash) }

        it 'return object' do
          expect(FileObject.get_directory_object_by_id_hash(id_hash)).to eq(root_object)
        end
      end

      context 'trash object' do
        let!(:trash_object) { FactoryGirl.create(:trash_object, id_hash: id_hash) }

        it 'return object' do
          expect(FileObject.get_directory_object_by_id_hash(id_hash)).to eq(trash_object)
        end
      end

      context 'directory object' do
        let!(:directory_object) { FactoryGirl.create(:directory_object, id_hash: id_hash) }

        it 'return object' do
          expect(FileObject.get_directory_object_by_id_hash(id_hash)).to eq(directory_object)
        end
      end

      context 'file object' do
        before(:each) do
          FactoryGirl.build(:file_object, id_hash: id_hash)
        end

        it 'not return object' do
          expect(FileObject.get_directory_object_by_id_hash(id_hash)).to be_nil
        end
      end
    end

    describe 'get_file_or_directory_object_by_id_hash' do
      context 'root object' do
        before(:each) do
          FactoryGirl.build(:root_object, id_hash: id_hash)
        end

        it 'not return object' do
          expect(FileObject.get_file_or_directory_object_by_id_hash(id_hash)).to be_nil
        end
      end

      context 'trash object' do
        before(:each) do
          FactoryGirl.build(:trash_object, id_hash: id_hash)
        end

        it 'not return object' do
          expect(FileObject.get_file_or_directory_object_by_id_hash(id_hash)).to be_nil
        end
      end

      context 'directory object' do
        let!(:directory_object) { FactoryGirl.create(:directory_object, id_hash: id_hash) }

        it 'return object' do
          expect(FileObject.get_file_or_directory_object_by_id_hash(id_hash)).to eq(directory_object)
        end
      end

      context 'file object' do
        before(:each) do
          file_object[:id_hash] = id_hash
          file_object.save
        end

        it 'return object' do
          expect(FileObject.get_file_or_directory_object_by_id_hash(id_hash)).to eq(file_object)
        end
      end
    end

    describe 'get_file_or_directory_object_by_id_hashes' do
      context 'root object' do
        before(:each) do
          FactoryGirl.build(:root_object, id_hash: id_hash)
        end

        it 'not return object' do
          expect(FileObject.get_file_or_directory_object_by_id_hashes([id_hash])).to be_empty
        end
      end

      context 'trash object' do
        before(:each) do
          FactoryGirl.build(:trash_object, id_hash: id_hash)
        end

        it 'not return object' do
          expect(FileObject.get_file_or_directory_object_by_id_hashes([id_hash])).to be_empty
        end
      end

      context 'directory object' do
        let!(:directory_object) { FactoryGirl.create(:directory_object, id_hash: id_hash) }

        it 'return object' do
          expect(FileObject.get_file_or_directory_object_by_id_hashes([id_hash])).to eq([directory_object])
        end
      end

      context 'file object' do
        before(:each) do
          file_object[:id_hash] = id_hash
          file_object.save
        end

        it 'return object' do
          expect(FileObject.get_file_or_directory_object_by_id_hashes([id_hash])).to eq([file_object])
        end
      end
    end

    describe 'get_trash_object' do
      before(:each) do
        FactoryGirl.build(:root_object)
        FactoryGirl.build(:directory_object)
        FactoryGirl.build(:file_object)
      end

      let!(:trash_object) { FactoryGirl.create(:trash_object) }

      it 'return trash object' do
        expect(FileObject.get_trash_object).to eq(trash_object)
      end
    end
  end

  describe 'instance methods' do
    describe 'file_upload' do
      before(:each) do
        expect(FileUtils).to receive(:mkdir_p) #.with #TODO
        expect(File).to receive(:open) #.with #TODO

        allow(dummy_file).to receive(:read) { 'dummy' }
        allow(dummy_file).to receive(:original_filename) { 'dummy' }
        allow(dummy_file).to receive(:size) { 0 }

        file_object[:parent_directory_id] = root_object[:id]
        file_object.save

        file_object.file_upload(dummy_file)
      end

      let(:dummy_file) { {} }
      let(:root_object) { FactoryGirl.create(:root_object) }

      it 'save file' do
        expect(file_object.persisted?).to be_truthy
      end
    end

    describe 'directory_make' do
      let(:root_object) { FactoryGirl.create(:root_object) }
      let(:new_directory_name) { 'new' }

      it 'make directory object' do
        expect {
          root_object.directory_make(new_directory_name)
        }.to change { FileObject.where(name: new_directory_name).count }.by(1)
      end
    end

    describe 'object_rename' do
      before(:each) do
        file_object[:parent_directory_id] = root_object[:id]
      end

      let(:root_object) { FactoryGirl.create(:root_object) }
      let(:new_file_name) { 'new' }

      it 'change file object name' do
        expect(file_object[:name]).not_to eq(new_file_name)
        file_object.object_rename(new_file_name)
        expect(file_object[:name]).to eq(new_file_name)
      end
    end

    describe 'object_paste' do
      before(:each) do
        file_object[:parent_directory_id] = root_object[:id]
        file_object.object_paste(directory_object[:id_hash])
      end

      let(:root_object) { FactoryGirl.create(:root_object) }
      let(:directory_object) { FactoryGirl.create(:directory_object, parent_directory_id: root_object[:id]) }

      it 'change directory of file object' do
        expect(file_object[:parent_directory_id]).to eq(directory_object[:id])
      end
    end

    describe 'object_delete' do
      context 'root object' do
        before(:each) do
          root_object.object_delete
        end

        let(:root_object) { FactoryGirl.build(:root_object) }

        it 'not delete root object' do
          expect(root_object.destroyed?).to be_falsy
        end
      end

      context 'trash object' do
        before(:each) do
          trash_object.object_delete
        end

        let(:trash_object) { FactoryGirl.build(:trash_object) }

        it 'not delete trash object' do
          expect(trash_object.destroyed?).to be_falsy
        end
      end

      context 'directory object' do
        context 'trash ancestor' do
          let(:trash_object) { FactoryGirl.create(:trash_object) }
          let(:directory_object) { FactoryGirl.create(:directory_object, parent_directory_id: trash_object[:id]) }

          it 'delete directry object' do
            directory_object.object_delete
            expect(directory_object.destroyed?).to be_truthy
          end
        end

        context 'root ancestor' do
          let(:root_object) { FactoryGirl.create(:root_object) }
          let!(:trash_object) { FactoryGirl.create(:trash_object) }
          let(:directory_object) { FactoryGirl.create(:directory_object, parent_directory_id: root_object[:id]) }

          it 'not delete directry object' do
            directory_object.object_delete
            expect(directory_object.destroyed?).to be_falsy
          end

          it 'move trash object' do
            expect(directory_object[:parent_directory_id]).to eq(root_object[:id])
            directory_object.object_delete
            expect(directory_object[:parent_directory_id]).to eq(trash_object[:id])
          end
        end
      end

      context 'file object' do
        context 'trash ancestor' do
          before(:each) do
            file_object[:parent_directory_id] = trash_object[:id]
            file_object.save

            expect(FileUtils).to receive(:rm).with(file_object.file_fullpath)
          end

          let(:trash_object) { FactoryGirl.create(:trash_object) }

          it 'delete file object' do
            file_object.object_delete
            expect(file_object.destroyed?).to be_truthy
          end
        end

        context 'root ancestor' do
          before(:each) do
            file_object[:parent_directory_id] = root_object[:id]
          end

          let(:root_object) { FactoryGirl.create(:root_object) }
          let!(:trash_object) { FactoryGirl.create(:trash_object) }

          it 'not delete file object' do
            file_object.object_delete
            expect(file_object.destroyed?).to be_falsy
          end

          it 'move trash object' do
            expect(file_object[:parent_directory_id]).to eq(root_object[:id])
            file_object.object_delete
            expect(file_object[:parent_directory_id]).to eq(trash_object[:id])
          end
        end
      end
    end

    describe 'is_root?' do
      let(:root_object) { FactoryGirl.build(:root_object) }
      let(:trash_object) { FactoryGirl.build(:trash_object) }
      let(:directory_object) { FactoryGirl.build(:directory_object) }

      it 'root_object:true else false' do
        expect(root_object.is_root?).to be_truthy
        expect(trash_object.is_root?).to be_falsy
        expect(directory_object.is_root?).to be_falsy
        expect(file_object.is_root?).to be_falsy
      end
    end

    describe 'is_trash?' do
      let(:root_object) { FactoryGirl.build(:root_object) }
      let(:trash_object) { FactoryGirl.build(:trash_object) }
      let(:directory_object) { FactoryGirl.build(:directory_object) }

      it 'trash_object:true else false' do
        expect(root_object.is_trash?).to be_falsy
        expect(trash_object.is_trash?).to be_truthy
        expect(directory_object.is_trash?).to be_falsy
        expect(file_object.is_trash?).to be_falsy
      end
    end

    describe 'is_directory?' do
      let(:root_object) { FactoryGirl.build(:root_object) }
      let(:trash_object) { FactoryGirl.build(:trash_object) }
      let(:directory_object) { FactoryGirl.build(:directory_object) }

      it 'directory_object:true else false' do
        expect(root_object.is_directory?).to be_falsy
        expect(trash_object.is_directory?).to be_falsy
        expect(directory_object.is_directory?).to be_truthy
        expect(file_object.is_directory?).to be_falsy
      end
    end

    describe 'is_file?' do
      let(:root_object) { FactoryGirl.build(:root_object) }
      let(:trash_object) { FactoryGirl.build(:trash_object) }
      let(:directory_object) { FactoryGirl.build(:directory_object) }

      it 'file_object:true else false' do
        expect(root_object.is_file?).to be_falsy
        expect(trash_object.is_file?).to be_falsy
        expect(directory_object.is_file?).to be_falsy
        expect(file_object.is_file?).to be_truthy
      end
    end

    describe 'updated_at_h' do
      let(:trash_object) { FactoryGirl.create(:trash_object) }

      it 'return easy to read date' do
        expect(trash_object.updated_at_h).to eq(trash_object.updated_at.strftime("%Y/%m/%d %T"))
      end
    end

    describe 'file_fullpath' do
      it 'return fullpath' do
        expect(file_object.file_fullpath).to eq(File.join(data_path, file_object[:file_hash][0, 2], file_object[:file_hash]))
      end
    end

    describe 'get_parent_directories_list' do
      context 'root object' do
        before(:each) do
          file_object[:parent_directory_id] = root_object[:id]
          file_object.save
        end

        let(:root_object) { FactoryGirl.create(:root_object) }

        let(:result) do
          [
            { id_hash: root_object[:id_hash], name: root_object[:name] },
            { id_hash: file_object[:id_hash], name: file_object[:name] },
          ]
        end

        it 'return file_object to root_object' do
          expect(file_object.get_parent_directories_list).to eq(result)
        end
      end
    end

    describe 'file_save_path' do
      it 'return savepath' do
        expect(file_object.file_save_path).to eq(File.join(data_path, file_object[:file_hash][0, 2]))
      end
    end

    describe 'is_trash_ancestor?' do
      context 'root ancestor?' do
        before(:each) do
          file_object[:parent_directory_id] = root_object[:id]
        end

        let(:root_object) { FactoryGirl.create(:root_object) }

        it "return false" do
          expect(file_object.is_trash_ancestor?).to be_falsy
        end
      end

      context 'trash ancestor?' do
        before(:each) do
          file_object[:parent_directory_id] = trash_object[:id]
        end

        let(:trash_object) { FactoryGirl.create(:trash_object) }

        it "return true" do
          expect(file_object.is_trash_ancestor?).to be_truthy
        end
      end
    end
  end
end
