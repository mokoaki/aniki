FactoryGirl.define do
  factory :root_object, class: FileObject do
    name 'root'
    parent_directory_id_hash ''
    object_mode 1
    id_hash 'root'
  end

  factory :trash_object, class: FileObject do
    name 'ゴミ箱'
    parent_directory_id_hash 'root'
    object_mode 2
    id_hash 'gomibako'
  end

  factory :directory_object, class: FileObject do
    name 'directory_object'
    parent_directory_id_hash 'root'
    object_mode 3
    id_hash 'directory_object'
  end

  factory :file_object do
    name 'file_object'
    parent_directory_id_hash 'root'
    object_mode 4
    id_hash 'file_object'
    file_hash 'file_object'
  end

  factory :user do
    login_id 'hogehoge'
    password 'hugahuga'
    password_confirmation 'hugahuga'
  end
end
