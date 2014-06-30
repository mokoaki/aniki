require 'rails_helper'

describe "IntegrationTests", js: true do #, :type => :request do
  describe '未ログイン状態' do
    context 'root_path' do
      it 'ログイン画面表示' do
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
          fill_in 'password', with: 'aaaa'
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
    context 'adminユーザ' do
      before do
        visit root_path
        @user              = FactoryGirl.create(:user, admin: true)
        @root_object      = FactoryGirl.create(:root_object)
        @trash_object     = FactoryGirl.create(:trash_object, parent_directory_id: @root_object.id)
        @directory_object = FactoryGirl.create(:directory_object, parent_directory_id: @root_object.id)

        fill_in 'login_id', with: @user.login_id
        fill_in 'password', with: @user.password

        click_button 'ログイン'
      end

      it 'ユーザ情報変更' do
        expect(find('button#rename_file_object_menu_button').visible?).to be_truthy

        click_button 'ユーザ情報変更'

        expect(find('input#user_login_id').value).to eq(@user.login_id)
        expect(find('input#user_password').value).to eq('')
        expect(find('input#user_password_confirmation').value).to eq('')

        fill_in 'user_login_id',              with: 'test'
        fill_in 'user_password',              with: 'aaaaaa'
        fill_in 'user_password_confirmation', with: 'aaaaaaa'

        temp_user = User.find_by(id: @user.id)
        user_login_id        = temp_user.login_id
        user_password_digest = temp_user.password_digest

        click_button '変更'

        temp_user = User.find_by(id: @user.id)
        expect(temp_user.login_id).to eq(user_login_id)
        expect(temp_user.password_digest).to eq(user_password_digest)
        expect(page).to have_content('失敗した')

        fill_in 'user_login_id',              with: 'test'
        fill_in 'user_password',              with: 'aaaaaa'
        fill_in 'user_password_confirmation', with: 'aaaaaa'

        click_button '変更'

        temp_user = User.find_by(id: @user.id)
        expect(temp_user.login_id).to eq('test')
        expect(temp_user.password_digest).not_to eq(user_password_digest)
        expect(page).to have_content('更新した')
      end

      it '新規ユーザ追加' do
        expect(find('button#rename_file_object_menu_button').visible?).to be_truthy

        click_button 'ユーザ新規作成'

        expect(find('input#user_login_id').value).to eq('')
        expect(find('input#user_password').value).to eq('')
        expect(find('input#user_password_confirmation').value).to eq('')

        fill_in 'user_login_id',              with: 'test'
        fill_in 'user_password',              with: 'aaaaaa'
        fill_in 'user_password_confirmation', with: 'aaaaaaa'

        user_count = User.count

        click_button '作成'

        expect(User.count).to eq(user_count)
        expect(page).to have_content('失敗した')

        fill_in 'user_login_id',              with: 'test'
        fill_in 'user_password',              with: 'aaaaaa'
        fill_in 'user_password_confirmation', with: 'aaaaaa'

        click_button '作成'

        expect(User.count).to eq(user_count + 1)
        expect(current_path).to eq(directory_path(FileObject.get_root_object.id))
        expect(page).to have_content('作成した')
      end

      it '新規ディレクトリ' do
        expect(find('div#new_directory_form', visible: false).visible?).to be_falsy

        click_button '新規ディレクトリ'

        expect(find('div#new_directory_form').visible?).to be_truthy

        fill_in 'name', with: '新規ディレクトリ名'

        expect(find('div#files')).not_to have_content('新規ディレクトリ名')

        directory_count = FileObject.where(object_mode: 3).count

        click_button 'ディレクトリ作成'

        expect(find('div#files')).to have_content('新規ディレクトリ名')
        expect(FileObject.where(object_mode: 3).count).to eq(directory_count + 1)
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

      context '削除ボタン' do
        it 'root' do
          expect(find('button#delete_file_object_menu_button').disabled?).to be_truthy
          expect(find("input#file_object_checks_#{@directory_object.id}").visible?).to be_truthy

          check "file_object_checks_#{@directory_object.id}"

          expect(find('button#delete_file_object_menu_button').disabled?).to be_falsy

          root_children_count = @root_object.children.size
          directory_count = FileObject.count

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
          expect(@root_object.children.size).to eq(root_children_count - 1)
          expect(FileObject.count).to eq(directory_count)
        end

        it 'ゴミ箱' do
          trash_file_object = FactoryGirl.create(:file_object, parent_directory_id: @trash_object.id)

          visit directory_path(@trash_object.id)

          expect(find('button#delete_file_object_menu_button').disabled?).to be_truthy
          expect(find("input#file_object_checks_#{trash_file_object.id}").visible?).to be_truthy

          check "file_object_checks_#{trash_file_object.id}"

          expect(find('button#delete_file_object_menu_button').disabled?).to be_falsy

          trash_children_count = @trash_object.children.size
          file_count = FileObject.count

          click_button '削除'

          #poltergeistだと動かない　ていうか常にwindow.confirmにはtrueで返す
          #page.driver.browser.switch_to.alert.accept

          #scriptで要素が消えるまでにちょっと時間がかかるようなので
          #ループして消えるのを待つ。ていうかもうちょっと良い書き方があると思う 無限ループも怖いし
          begin
            while find("div#line_#{trash_file_object.id}")
              sleep 0.5
            end
          rescue
          end

          expect { find("a#link_#{trash_file_object.id}") }.to raise_error(Capybara::ElementNotFound)
          expect(@trash_object.children.size).to eq(trash_children_count - 1)
          expect(FileObject.count).to eq(file_count - 1)
        end
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

    context '一般ユーザ' do
    end
  end
end
