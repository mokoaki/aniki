FactoryGirl.define do
  factory :file_object do
    name 'file_object'
    object_mode 4

    factory :root_object, class: FileObject do
      name 'root'
      parent_directory_id 0
      object_mode 1
    end

    factory :trash_object, class: FileObject do
      name 'ゴミ箱'
      object_mode 2
    end

    factory :directory_object, class: FileObject do
      name 'ディレクトリ名'
      object_mode 3
    end
  end

  factory :user do
    login_id 'mokoaki'
    password 'mokoaki'
    password_confirmation 'mokoaki'
  end
end
