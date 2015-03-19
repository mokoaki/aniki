require 'rails_helper'

describe FileObject do
  let(:root_object)      { FactoryGirl.build(:root_object) }
  let(:trash_object)     { FactoryGirl.build(:trash_object) }
  let(:directory_object) { FactoryGirl.build(:directory_object) }
  let(:file_object)      { FactoryGirl.build(:file_object) }

  context 'check methods' do
    it 'columns' do
      expect(file_object).to respond_to(:name)
      expect(file_object).to respond_to(:parent_directory_id_hash)
      expect(file_object).to respond_to(:object_mode)
      expect(file_object).to respond_to(:id_hash)
      expect(file_object).to respond_to(:file_hash)
      expect(file_object).to respond_to(:size)
      expect(file_object).to respond_to(:created_at)
      expect(file_object).to respond_to(:updated_at)
    end

    it 'class methods' do
      expect(FileObject).to respond_to(:get_trash_object)
      expect(FileObject).to respond_to(:get_children_by_id_hash)
      expect(FileObject).to respond_to(:get_directory_object_by_id_hash)
      expect(FileObject).to respond_to(:get_file_or_directory_object_by_id_hash)
      expect(FileObject).to respond_to(:get_file_object_by_id_hash)
      expect(FileObject).to respond_to(:create_directory)
      expect(FileObject).to respond_to(:upload_file)
      expect(FileObject).to respond_to(:get_random_sha1)
    end

    it 'instance methods' do
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
      expect(file_object).to respond_to(:is_mine_ancestor?)
    end

    it 'relations' do
      expect(file_object).to respond_to(:parent_directory)
      expect(file_object).to respond_to(:children)
    end
  end

  describe 'validation' do
    before(:each) do
      root_object.save
    end

    it 'default valid' do
      expect(root_object).to be_valid
      expect(trash_object).to be_valid
      expect(directory_object).to be_valid
      expect(file_object).to be_valid
    end

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

    context 'parent_directory_id_hash' do
      it 'nil invalid' do
        file_object[:parent_directory_id_hash] = nil
        expect(file_object).to be_invalid
      end

      it 'null_character invalid' do
        file_object[:parent_directory_id_hash] = ''
        expect(file_object).to be_invalid
      end

      it 'space invalid' do
        file_object[:parent_directory_id_hash] = ' '
        expect(file_object).to be_invalid
      end

      it 'A invalid' do
        file_object[:parent_directory_id_hash] = 'A'
        expect(file_object).to be_invalid
      end

      it 'file_object parent_directory_id_hash: "" invalid' do
        file_object[:parent_directory_id_hash] = ''
        expect(file_object).to be_invalid
      end

      it 'root_object parent_directory_id_hash: "" valid' do
        root_object[:parent_directory_id_hash] = ''
        expect(root_object).to be_valid
      end

      it 'file_object parent_directory_id_hash: "root" valid' do
        file_object[:parent_directory_id_hash] = 'root'
        expect(file_object).to be_valid
      end

      it 'root_object parent_directory_id_hash: "root" invalid' do
        root_object[:parent_directory_id_hash] = 'root'
        expect(root_object).to be_invalid
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
    describe 'parent_directory' do
      before(:each) do
        root_object.save
      end

      it 'return root object' do
        expect(file_object.parent_directory).to eq(root_object)
      end
    end

    describe 'children' do
      before(:each) do
        root_object.save
        file_object.save
      end

      it 'return file object' do
        expect(root_object.children).to eq([file_object])
      end
    end
  end

  describe 'event' do
    describe 'before_destroy' do
      context 'root object' do
        it 'fail destroy' do
          root_object.destroy
          expect(root_object.destroyed?).to be_falsy
        end
      end

      context 'trash object' do
        it 'fail destroy' do
          trash_object.save
          trash_object.destroy
          expect(trash_object.destroyed?).to be_falsy
        end
      end

      context 'directory object' do
        before(:each) do
          directory_object.save
          directory_object.destroy
        end

        it 'sucess destroy' do
          expect(directory_object.destroyed?).to be_truthy
        end
      end

      context 'file object' do
        context 'Not rm' do
          before(:each) do
            root_object.save
            file_object.save
            file_object2 = FactoryGirl.create(:file_object, { id_hash: 'test' })
          end

          it 'sucess destroy' do
            expect(FileUtils).not_to receive(:rm).with(file_object.file_fullpath)
            file_object.destroy
            expect(file_object.destroyed?).to be_truthy
          end
        end

        context 'There is only one FileObject you are referring to the same file' do
          before(:each) do
            root_object.save
            file_object.save
          end

          it 'sucess destroy' do
            expect(FileUtils).to receive(:rm).with(file_object.file_fullpath)
            file_object.destroy
            expect(file_object.destroyed?).to be_truthy
          end
        end
      end
    end

    describe 'before_save' do
      before(:each) do
        root_object.save
        file_object[:name] = "\n\t\\\"<a>'*:;b?|/"
        file_object.save
      end

      it 'replace string' do
        expect(file_object.name).to eq('”＜a＞’＊：；b？｜／')
      end
    end
  end

  describe 'class methods' do
    describe 'get_trash_object' do
      before(:each) do
        root_object.save
        trash_object.save
      end

      it 'return trash object' do
        expect(FileObject.get_trash_object).to eq(trash_object)
      end
    end

    describe 'get_children_by_id_hash' do
      before(:each) do
        root_object.save
        directory_object.save
        file_object[:parent_directory_id_hash] = directory_object[:id_hash]
        file_object.save
      end

      it 'return children' do
        file_object2 = FactoryGirl.build(:file_object)
        file_object2[:id_hash]                  = 'test1'
        file_object2[:parent_directory_id_hash] = directory_object[:id_hash]
        file_object2.save

        file_object3 = FactoryGirl.build(:file_object)
        file_object3[:id_hash]                  = 'test2'
        file_object3[:parent_directory_id_hash] = root_object[:id_hash]
        file_object3.save

        expect(FileObject.get_children_by_id_hash(directory_object[:id_hash])).to eq([file_object, file_object2])
      end
    end

    describe 'get_directory_object_by_id_hash' do
      context 'root object' do
        before(:each) do
          root_object.save
        end

        it 'return object' do
          expect(FileObject.get_directory_object_by_id_hash(root_object[:id_hash])).to eq(root_object)
        end
      end

      context 'file object' do
        before(:each) do
          file_object.save
        end

        it 'not return object' do
          expect(FileObject.get_directory_object_by_id_hash(file_object[:id_hash])).to be_nil
        end
      end
    end

    describe 'get_file_or_directory_object_by_id_hash' do
      context 'root object' do
        before(:each) do
          root_object.save
        end

        it 'not return object' do
          expect(FileObject.get_file_or_directory_object_by_id_hash(root_object[:id_hash])).to be_nil
        end
      end

      context 'file object' do
        before(:each) do
          root_object.save
          file_object.save
        end

        it 'return object' do
          expect(FileObject.get_file_or_directory_object_by_id_hash(file_object[:id_hash])).to eq(file_object)
        end
      end
    end

    describe 'get_file_object_by_id_hash' do
      context 'root object' do
        before(:each) do
          root_object.save
        end

        it 'not return object' do
          expect(FileObject.get_file_object_by_id_hash(root_object[:id_hash])).to be_nil
        end
      end

      context 'trash object' do
        before(:each) do
          root_object.save
          trash_object.save
        end

        it 'not return object' do
          expect(FileObject.get_file_object_by_id_hash(trash_object[:id_hash])).to be_nil
        end
      end

      context 'directory object' do
        before(:each) do
          root_object.save
          directory_object.save
        end

        it 'not return object' do
          expect(FileObject.get_file_object_by_id_hash(directory_object[:id_hash])).to be_nil
        end
      end

      context 'file object' do
        before(:each) do
          root_object.save
          file_object.save
        end

        it 'return object' do
          expect(FileObject.get_file_object_by_id_hash(file_object[:id_hash])).to eq(file_object)
        end
      end
    end

    describe 'create_directory' do
      before(:each) do
        root_object.save
      end

      let(:params) do
        {
          name: 'name',
          parent_directory_id_hash: root_object[:id_hash],
        }
      end

      it 'inclement directory object' do
        expect {
          FileObject.create_directory(params)
        }.to change { FileObject.where(object_mode: 3).count }.by(1)
      end

      it 'check params' do
        directory_object = FileObject.create_directory(params)
        expect(directory_object[:name]).to eq(params[:name])
        expect(directory_object[:parent_directory_id_hash]).to eq(root_object[:id_hash])
        expect(directory_object[:object_mode]).to eq(3)
        expect(directory_object[:id_hash]).to match(/\A[a-f\d]{40}\z/)
      end
    end

    describe 'upload_file' do
      before(:each) do
        root_object.save

        expect(FileUtils).to receive(:mkdir_p) #.with #TODO
        expect(File).to receive(:open) #.with #TODO

        allow(dummy_file).to receive(:read) { 'dummy' }
        allow(dummy_file).to receive(:original_filename) { original_filename }
        allow(dummy_file).to receive(:size) { size }
      end

      let(:dummy_file) { {} }
      let(:original_filename) { 'dummy' }
      let(:size) { 0 }

      let(:params) do
        {
          file: dummy_file,
          parent_directory_id_hash: root_object[:id_hash],
        }
      end

      it 'inclement file object' do
        expect {
          FileObject.upload_file(params)
        }.to change { FileObject.where(object_mode: 4).count }.by(1)
      end

      it 'check params' do
        file_object = FileObject.upload_file(params)
        expect(file_object[:name]).to eq(original_filename)
        expect(file_object[:parent_directory_id_hash]).to eq(root_object[:id_hash])
        expect(file_object[:object_mode]).to eq(4)
        expect(file_object[:id_hash]).to match(/\A[a-f\d]{40}\z/)
        expect(file_object[:file_hash]).to match(/\A[a-f\d]{40}\z/)
        expect(file_object[:size]).to eq(size)
      end
    end
  end

  describe 'get_random_sha1' do
    it 'match regex' do
      expect(FileObject.get_random_sha1).to match(/\A[a-f\d]{40}\z/)
    end
  end

  describe 'instance methods' do
    describe 'object_delete' do
      context 'root object' do
        before(:each) do
          root_object.save
          root_object.object_delete
        end

        it 'not delete root object' do
          expect(root_object.destroyed?).to be_falsy
        end
      end

      context 'trash object' do
        before(:each) do
          root_object.save
          trash_object.save
          trash_object.object_delete
        end

        it 'not delete trash object' do
          expect(trash_object.destroyed?).to be_falsy
        end
      end

      context 'directory object' do
        context 'trash ancestor' do
          before(:each) do
            root_object.save
            trash_object.save
            directory_object[:parent_directory_id_hash] = trash_object[:id_hash]
            directory_object.save
            file_object[:parent_directory_id_hash] = directory_object[:id_hash]
            file_object.save
          end

          it 'delete object' do
            expect(FileUtils).to receive(:rm).with(file_object.file_fullpath)
            directory_object.object_delete
            expect(directory_object.destroyed?).to be_truthy
          end
        end

        context 'root ancestor' do
          before(:each) do
            root_object.save
            trash_object.save
            directory_object.save
            file_object[:parent_directory_id_hash] = directory_object[:id_hash]
            file_object.save
          end

          it 'not delete object' do
            directory_object.object_delete
            expect(directory_object.destroyed?).to be_falsy
            expect(file_object.destroyed?).to be_falsy
          end

          it 'move trash object' do
            expect(directory_object[:parent_directory_id_hash]).to eq(root_object[:id_hash])
            directory_object.object_delete
            expect(directory_object[:parent_directory_id_hash]).to eq(trash_object[:id_hash])
          end
        end
      end

      context 'file object' do
        context 'trash ancestor' do
          before(:each) do
            root_object.save
            trash_object.save
            file_object[:parent_directory_id_hash] = trash_object[:id_hash]
            file_object.save
          end

          it 'delete file object' do
            expect(FileUtils).to receive(:rm).with(file_object.file_fullpath)
            file_object.object_delete
            expect(file_object.destroyed?).to be_truthy
          end
        end

        context 'root ancestor' do
          before(:each) do
            root_object.save
            trash_object.save
            file_object.save
          end

          it 'not delete file object' do
            file_object.object_delete
            expect(file_object.destroyed?).to be_falsy
          end

          it 'move trash object' do
            expect(file_object[:parent_directory_id_hash]).to eq(root_object[:id_hash])
            file_object.object_delete
            expect(file_object[:parent_directory_id_hash]).to eq(trash_object[:id_hash])
          end
        end
      end
    end

    describe 'is_root?' do
      it 'root_object:true else false' do
        expect(root_object.is_root?).to be_truthy
        expect(trash_object.is_root?).to be_falsy
        expect(directory_object.is_root?).to be_falsy
        expect(file_object.is_root?).to be_falsy
      end
    end

    describe 'is_trash?' do
      it 'trash_object:true else false' do
        expect(root_object.is_trash?).to be_falsy
        expect(trash_object.is_trash?).to be_truthy
        expect(directory_object.is_trash?).to be_falsy
        expect(file_object.is_trash?).to be_falsy
      end
    end

    describe 'is_directory?' do
      it 'directory_object:true else false' do
        expect(root_object.is_directory?).to be_falsy
        expect(trash_object.is_directory?).to be_falsy
        expect(directory_object.is_directory?).to be_truthy
        expect(file_object.is_directory?).to be_falsy
      end
    end

    describe 'is_file?' do
      it 'file_object:true else false' do
        expect(root_object.is_file?).to be_falsy
        expect(trash_object.is_file?).to be_falsy
        expect(directory_object.is_file?).to be_falsy
        expect(file_object.is_file?).to be_truthy
      end
    end

    describe 'updated_at_h' do
      before(:each) do
        root_object.save
      end

      it 'return easy to read date' do
        expect(root_object.updated_at_h).to eq(root_object.updated_at.strftime("%Y/%m/%d %T"))
      end
    end

    describe 'file_fullpath' do
      let(:data_path) { Rails.application.secrets.data_path }

      it 'return fullpath' do
        expect(file_object.file_fullpath).to eq(File.join(data_path, file_object[:file_hash][0, 2], file_object[:file_hash]))
      end
    end

    describe 'get_parent_directories_list' do
      context 'root object' do
        before(:each) do
          root_object.save
          file_object.save
        end

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
      let(:data_path) { Rails.application.secrets.data_path }

      it 'return savepath' do
        expect(file_object.file_save_path).to eq(File.join(data_path, file_object[:file_hash][0, 2]))
      end
    end

    describe 'is_trash_ancestor?' do
      context 'root ancestor?' do
        before(:each) do
          root_object.save
        end

        it "return false" do
          expect(file_object.is_trash_ancestor?).to be_falsy
        end
      end

      context 'trash ancestor?' do
        before(:each) do
          root_object.save
          trash_object.save
          file_object[:parent_directory_id_hash] = trash_object[:id_hash]
        end

        it "return true" do
          expect(file_object.is_trash_ancestor?).to be_truthy
        end
      end
    end

    describe "is_mine_ancestor?" do
      before(:each) do
        root_object.save
        directory_object.save
      end

      let(:directory_object2) do
        FactoryGirl.create(:directory_object, {id_hash: 'directory_object2', parent_directory_id_hash: directory_object[:id_hash]})
      end

      it 'ok' do
        expect(directory_object2.is_mine_ancestor?).to be_falsy
      end

      it 'ng' do
        directory_object[:parent_directory_id_hash] = directory_object2[:id_hash]
        expect(directory_object.is_mine_ancestor?).to be_truthy
      end
    end
  end
end
