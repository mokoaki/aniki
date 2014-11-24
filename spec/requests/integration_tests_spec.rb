require 'rails_helper'

describe 'IntegrationTests', js: true do
  let!(:root_object)       { FactoryGirl.create(:root_object) }
  let!(:trash_object)      { FactoryGirl.create(:trash_object,     parent_directory_id: root_object.id) }
  let!(:directory_object)  { FactoryGirl.create(:directory_object, parent_directory_id: root_object.id) }
  let!(:file_object)       { FactoryGirl.create(:file_object,      parent_directory_id: root_object.id) }
  let(:user)               { FactoryGirl.create(:user, admin: true) }

  context 'not login' do
    context 'get main page' do
      before(:each) do
        visit root_path
      end

      it 'display login page' do
        expect(current_path).to eq(login_path)
        expect(page).to have_content('ログインID')
      end
    end

    context 'login try' do
      context 'login fail' do
        before(:each) do
          visit login_path

          fill_in 'login_id', with: user.login_id
          fill_in 'password', with: 'aaaa'
          click_button 'ログイン'
        end

        it 'display fail message' do
          expect(current_path).to eq(login_try_path)
          expect(page).to have_content('ログイン失敗')
        end
      end

      context 'success' do
        before(:each) do
          visit root_path

          fill_in 'login_id', with: user.login_id
          fill_in 'password', with: user.password
          click_button 'ログイン'
        end

        context 'normal user' do
          let(:user) { FactoryGirl.create(:user) }

          it 'diaplay success message' do
            expect(current_path).to eq(root_path)

            expect(find('button#menu_upload_file_button').disabled?).to be_falsy
            expect(find('button#menu_new_directory_button').disabled?).to be_falsy
            expect(find('button#menu_rename_file_object_button').disabled?).to be_truthy
            expect(find('button#menu_cut_file_object_button').disabled?).to be_truthy
            expect(find('button#menu_paste_file_object_button').disabled?).to be_truthy
            expect(find('button#menu_delete_file_object_button').disabled?).to be_truthy
            expect(find('button#menu_edit_user_data_button').disabled?).to be_falsy
          end
        end

        context 'adminユーザ' do
          it 'diaplay success message' do
            expect(current_path).to eq(root_path)

            expect(find('button#menu_upload_file_button').disabled?).to be_falsy
            expect(find('button#menu_new_directory_button').disabled?).to be_falsy
            expect(find('button#menu_rename_file_object_button').disabled?).to be_truthy
            expect(find('button#menu_cut_file_object_button').disabled?).to be_truthy
            expect(find('button#menu_paste_file_object_button').disabled?).to be_truthy
            expect(find('button#menu_delete_file_object_button').disabled?).to be_truthy
            expect(find('button#menu_edit_user_data_button').disabled?).to be_falsy
            expect(find('button#menu_new_user_data_button').disabled?).to be_falsy
          end
        end
      end
    end
  end

  describe 'already login' do
    before(:each) do
      visit root_path

      fill_in 'login_id', with: user.login_id
      fill_in 'password', with: user.password
      click_button 'ログイン'
    end

    pending 'check box'
      pending 'all check click'
      pending 'shift + check click'

    context 'menu' do
      pending 'new directory' do
        expect(find('div#new_directory_form', visible: false).visible?).to be_falsy

        click_button 'ディレクトリ作成'
        expect(find('div#new_directory_form').visible?).to be_truthy

        fill_in 'new_directory_name', with: '新規ディレクトリ名'
        directory_count = FileObject.where(object_mode: 3).count
        click_button 'ディレクトリ作成するで'

        wait_and_do(3) do
          FileObject.where(object_mode: 3).count == directory_count + 1
        end

        expect(FileObject.where(object_mode: 3).count).to eq(directory_count + 1)
      end

      pending 'rename' do
        expect(find('button#menu_rename_file_object_button').disabled?).to be_truthy

        check('#checkbox_1')
        check 'checkbox_2'

        expect(find('button#menu_rename_file_object_button').disabled?).to be_falsy

        click_button 'リネーム'

        expect(find("span#name_object_#{directory_object[:id]}", visible: false).visible?).to be_falsy
        expect(find("span#rename_object_#{directory_object[:id]}").visible?).to be_truthy

        expect(find("input#rename_#{directory_object[:id]}").value).to eq('ディレクトリ名')

        fill_in "rename_#{directory_object[:id]}", with: 'ディレクトリ名変更後'

        click_button 'リネームするで'

        expect(find("span#name_object_#{directory_object[:id]}").visible?).to be_truthy
        expect(find("span#rename_object_#{directory_object[:id]}", visible: false).visible?).to be_falsy
        expect(find("a#link_#{directory_object[:id]}").text).to eq('ディレクトリ名変更後')
        expect(FileObject.get_directory_by_id(directory_object[:id]).name).to eq('ディレクトリ名変更後')
      end

      pending '削除ボタン' do
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

        visit directory_path(@trash_object.id)

        expect(find('button#delete_file_object_menu_button').disabled?).to be_truthy
        expect(find("input#file_object_checks_#{@directory_object.id}").visible?).to be_truthy

        check "file_object_checks_#{@directory_object.id}"

        expect(find('button#delete_file_object_menu_button').disabled?).to be_falsy

        trash_children_count = @trash_object.children.size
        file_count = FileObject.count

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
        expect(@trash_object.children.size).to eq(trash_children_count - 1)
        expect(FileObject.count).to eq(file_count - 1)
        expect(FileObject.get_directory_by_id(@directory_object.id)).to be_nil
      end

      pending 'カットボタン' do
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

      pending 'ユーザ情報変更' do
        expect(find('button#edit_password_menu_button').visible?).to be_truthy

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

      pending '新規ユーザ追加' do
        expect(find('button#new_user_menu_button').visible?).to be_truthy

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
    end
  end
end
