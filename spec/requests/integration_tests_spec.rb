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
          expect(page).to have_content('ログイン失敗')
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
      user              = FactoryGirl.create(:user)
      @root_object      = FactoryGirl.create(:root_object)
      @trash_object     = FactoryGirl.create(:trash_object, parent_directory_id: @root_object.id)
      @directory_object = FactoryGirl.create(:directory_object, parent_directory_id: @root_object.id)

      fill_in 'login_id', with: user.login_id
      fill_in 'password', with: user.password

      click_button 'ログイン'
    end

    it '新規ディレクトリ' do #, js: true do
      expect(find('div#new_directory_form', visible: false).visible?).to be_falsy

      click_button '新規ディレクトリ'

      expect(find('div#new_directory_form').visible?).to be_truthy

      fill_in 'name', with: '新規ディレクトリ名'

      expect(find('div#files')).not_to have_content('新規ディレクトリ名')

      click_button 'ディレクトリ作成'

      expect(find('div#files')).to have_content('新規ディレクトリ名')
    end

    it 'リネームボタン' do
      expect(find('button#rename_file_object_menu_button').disabled?).to be_truthy
      expect(find("input#file_object_checks_#{@directory_object.id}").visible?).to be_truthy
      expect(find("span#name_object_#{@directory_object.id}").visible?).to be_truthy
      expect(find("span#rename_object_#{@directory_object.id}", visible: false).visible?).to be_falsy
      expect(find("a#link_#{@directory_object.id}").text).to eq('ディレクトリ名')

      check "file_object_checks_#{@directory_object.id}"

      expect(find('button#rename_file_object_menu_button').disabled?).to be_falsy

      click_button 'リネーム'

      expect(find("span#name_object_#{@directory_object.id}", visible: false).visible?).to be_falsy
      expect(find("span#rename_object_#{@directory_object.id}").visible?).to be_truthy

      expect(find("input#rename_#{@directory_object.id}").value).to eq('ディレクトリ名')

      fill_in "rename_#{@directory_object.id}", with: 'ディレクトリ名変更後'

      click_button '変更'

      expect(find("span#name_object_#{@directory_object.id}").visible?).to be_truthy
      expect(find("span#rename_object_#{@directory_object.id}", visible: false).visible?).to be_falsy
      expect(find("a#link_#{@directory_object.id}").text).to eq('ディレクトリ名変更後')
    end

    it '削除ボタン' do
      expect(find('button#delete_file_object_menu_button').disabled?).to be_truthy
      expect(find("input#file_object_checks_#{@directory_object.id}").visible?).to be_truthy

      check "file_object_checks_#{@directory_object.id}"

      expect(find('button#delete_file_object_menu_button').disabled?).to be_falsy

      click_button '削除'

      #poltergeistだと動かない　ていうか常にwindow.confirmにはtrueで返す
      #page.driver.browser.switch_to.alert.accept

      #scriptで要素が消えるまでにちょっと時間がかかるようなので
      #ループして消えるのを待つ。ていうかもうちょっと良い書き方があると思う 無限ループも怖いし
      begin
        while find("div#line_#{@directory_object.id}")
          sleep 0.5
        end
      rescue
      end

      expect { find("a#link_#{@directory_object.id}") }.to raise_error(Capybara::ElementNotFound)
    end

    it 'カットボタン' do
      expect(find('button#cut_file_object_menu_button').disabled?).to be_truthy
      expect(find('button#paste_file_object_menu_button').disabled?).to be_truthy
      expect(find("input#file_object_checks_#{@directory_object.id}").visible?).to be_truthy

      check "file_object_checks_#{@directory_object.id}"

      expect(find('button#cut_file_object_menu_button').disabled?).to be_falsy
      expect(find('button#paste_file_object_menu_button').disabled?).to be_truthy

      click_button 'カット'

      #ちょっと待たないとスクリプトが終了しないっぽ
      sleep 0.5

      expect(find('button#paste_file_object_menu_button').disabled?).to be_falsy

      visit directory_path(FileObject.get_trash_object.id)

      expect(find('button#paste_file_object_menu_button').disabled?).to be_falsy
      expect { find("a#link_#{@directory_object.id}") }.to raise_error(Capybara::ElementNotFound)

      click_button 'ペースト'

      #ちょっと待たないとスクリプトが終了しないっぽ
      sleep 0.5

      expect(find('button#paste_file_object_menu_button').disabled?).to be_truthy
      expect(find("a#link_#{@directory_object.id}").text).to eq('ディレクトリ名')
    end
  end
end
