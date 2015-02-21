desc 'system initialize'
task :initialize => :environment do
  FileObject.delete_all

  puts '[OK] Delete all object'

  FileObject.find_or_create_by(parent_directory_id_hash: '',     object_mode: 1, id_hash: 'root',     name: 'root')
  FileObject.find_or_create_by(parent_directory_id_hash: 'root', object_mode: 2, id_hash: 'gomibako', name: 'ゴミ箱')

  puts '[OK] Reset root and gomibako object'

  FileUtils.rm_rf(Rails.application.secrets.data_path)

  puts '[OK] Delete all file'

  login_id = Rails.application.secrets.admin_login_id
  password = Rails.application.secrets.admin_password

  User.delete_all

  puts '[OK] Delete all user'

  user = User.new(login_id: login_id, password: password, password_confirmation: password, admin: true)

  if user.valid?
    user.save

    puts '[OK] Create admin user'
  else
    puts "[NG] #{user.errors.messages}"
  end
end
