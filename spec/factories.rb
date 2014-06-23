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
    id 1
    name 'root'
    parent_directory_id 0
    object_mode 1
  end

  factory :trash_object, class: FileObject do
    id 2
    name 'ゴミ箱'
    parent_directory_id 1
    object_mode 2
  end

  factory :directory_object, class: FileObject do
    id 3
    name 'ディレクトリ名'
    parent_directory_id 1
    object_mode 3
  end

  factory :file_object do
    id 4
    name 'ファイル名'
    parent_directory_id 1
    object_mode 4
    hash_name 'aaaa'
    size 100
  end

  factory :trash_file_object, class: FileObject do
    id 5
    name 'ファイル名'
    parent_directory_id 2
    object_mode 4
    hash_name 'aaaa'
    size 100
  end

  factory :user do
    login_id 'mokomoko'
    #sequence(:login_id) { |i| "mokomoko#{i}" }
    password 'abcdefghij'
    password_confirmation 'abcdefghij'
  end
end
