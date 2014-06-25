class CreateFileObjects < ActiveRecord::Migration
  def change
    create_table :file_objects do |t|
      t.string  :name, limit: 255
      t.integer :parent_directory_id

      #1 :ROOT
      #2 :ゴミ箱
      #3 :ディレクトリ
      #4 :ファイル
      t.integer :object_mode

      t.string  :hash_name, limit: 64
      t.integer :size

      t.datetime  :created_at
    end

    add_index :file_objects, :parent_directory_id
    add_index :file_objects, :object_mode
  end
end
