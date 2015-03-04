class CreateFileObjects < ActiveRecord::Migration
  def change
    create_table :file_objects do |t|
      t.string  :name, limit: 512
      t.string  :parent_directory_id_hash, limit: 40

      #1 :ROOT
      #2 :ゴミ箱
      #3 :ディレクトリ
      #4 :ファイル
      t.integer :object_mode

      t.string  :id_hash,                  limit: 40
      t.string  :file_hash,                limit: 40
      t.integer :size

      t.timestamps
    end

    add_index :file_objects, :id_hash, unique: true
    add_index :file_objects, :parent_directory_id_hash
  end
end
