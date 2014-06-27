require 'rails_helper'

describe "IntegrationTests", js: true do #, :type => :request do
  describe '未ログイン状態' do
    context 'root_path' do
      it 'ログイン画面は表示できる' do
        visit root_path

        expect(current_path).to eq(login_path)
        expect(page).to have_content('ログインID')
        expect(page).to have_title('アニキシステム')
      end

      context 'ログインテスト' do
        it '失敗' do
          visit root_path
          user = FactoryGirl.create(:user)
          fill_in 'login_id', with: user.login_id
          fill_in 'password', with: 'moko'
          click_button 'ログイン'

          expect(current_path).to eq(login_try_path)
          expect(page).to have_content('パス違くね？')
        end

        it '成功' do
          visit root_path
          user = FactoryGirl.create(:user)
          FactoryGirl.create(:root_object)

          fill_in 'login_id', with: user.login_id
          fill_in 'password', with: user.password

          click_button 'ログイン'

          expect(current_path).to eq(directory_path(FileObject.get_root_object.id))
          expect(page).to have_content('root')
        end
      end
    end

    it '内部画面はログイン画面へリダイレクト' do
      FactoryGirl.create(:root_object)
      visit directory_path(FileObject.get_root_object.id)

      expect(current_path).to eq(login_path)
    end
  end

  context 'ログイン状態' do
    before do
      visit root_path
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:root_object)

      fill_in 'login_id', with: user.login_id
      fill_in 'password', with: user.password
      click_button 'ログイン'
    end

    it '新規ディレクトリ' do #, js: true do
      #moko = find('div#new_directory_form')
      #save_screenshot('/home/moko/file.png')
      #puts '============'
      #puts current_path
      #puts find('div#files').inspect
      #puts find('div#files').visible?
      #puts find('div#new_directory_form').visible?
      #puts find('div#new_directory_form', visible: true).visible?

      expect(find('div#new_directory_form', visible: false).visible?).to be_falsy

      click_button '新規ディレクトリ'
      #puts '----------------'
      #puts find('div#new_directory_form').inspect #.visible?
      #moko2 = find('div#new_directory_form')
      #puts moko2.inspect

      #expect(page).not_to have_content('ディレクトリ作成')

      expect(find('div#new_directory_form', visible: true).visible?).to be_truthy

      fill_in 'name', with: '新規ディレクトリ名'

      #expect(find("#not_found_id")).to raise_error(Capybara::ElementNotFound)

      files_div = find('div#files')

      expect(files_div).not_to have_content('新規ディレクトリ名')

      click_button 'ディレクトリ作成'

      expect(files_div).to have_content('新規ディレクトリ名')


    end
  end
end
