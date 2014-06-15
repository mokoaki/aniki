class CreateFileObjects < ActiveRecord::Migration
  def change
    create_table :file_objects do |t|
      t.string  :name
      t.integer :parent_directory_id

      #1 :ゴミ箱
      #2 :ディレクトリ
      #3 :ファイル
      t.integer :object_mode

      t.string  :hash_name, limit: 64
      t.integer :size

      t.timestamps
    end

    add_index :file_objects, :parent_directory_id
    add_index :file_objects, :object_mode
  end
end
