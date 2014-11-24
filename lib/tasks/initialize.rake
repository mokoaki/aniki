desc 'system initialize'
task :initialize => :environment do
  FileObject.where(object_mode: [3, 4]).delete_all

  FileObject.find_or_create_by(name: 'root',  parent_directory_id: 0, object_mode: 1, id_hash: 'root')
  FileObject.find_or_create_by(name: 'ゴミ箱', parent_directory_id: 1, object_mode: 2, id_hash: 'gomibako')

  FileUtils.rm_rf(Rails.application.secrets.data_path)

  login_id = Rails.application.secrets.admin_login_id
  password = Rails.application.secrets.admin_password

  User.delete_all
  User.create(login_id: login_id, password: password, password_confirmation: password, admin: true)
end
