FactoryGirl.define do
  # factory :, class: FileObject do
  #   factory :moko do
  #     name 'moko'
  #   end
  #
  #   factory :aho do
  #     name 'aho'
  #   end
  # end

  factory :root_object, class: FileObject do
    name 'root'
    parent_directory_id 0
    object_mode 1
  end

  factory :trash_object, class: FileObject do
    name 'ゴミ箱'
    #parent_directory_id 1
    object_mode 2
  end

  factory :directory_object, class: FileObject do
    name 'ディレクトリ名'
    #parent_directory_id 1
    object_mode 3
  end

  factory :file_object do
    name 'file_object'
    #parent_directory_id 1
    object_mode 4
  end

  factory :trash_file_object, class: FileObject do
    name 'trash_file_object'
    #parent_directory_id 1
    object_mode 4
  end

  factory :user do
    login_id 'mokoaki'
    password 'mokoaki'
    password_confirmation 'mokoaki'
  end
end
