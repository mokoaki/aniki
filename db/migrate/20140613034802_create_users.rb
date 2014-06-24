class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :login_id,        limit: 64
      t.string  :password_digest, limit: 60
      t.string  :remember_token,  limit: 64
      t.boolean :admin, default: false

      t.timestamps
    end

    add_index :users, :login_id, unique: true
    add_index :users, :remember_token
  end
end
