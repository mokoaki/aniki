# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140614042712) do

  create_table "file_objects", force: :cascade do |t|
    t.string   "name",                     limit: 512
    t.string   "parent_directory_id_hash", limit: 40
    t.integer  "object_mode",              limit: 4
    t.string   "id_hash",                  limit: 40
    t.string   "file_hash",                limit: 40
    t.integer  "size",                     limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "file_objects", ["id_hash"], name: "index_file_objects_on_id_hash", unique: true, using: :btree
  add_index "file_objects", ["parent_directory_id_hash"], name: "index_file_objects_on_parent_directory_id_hash", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login_id",        limit: 64
    t.string   "password_digest", limit: 60
    t.string   "remember_token",  limit: 64
    t.boolean  "admin",           limit: 1,  default: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "users", ["login_id"], name: "index_users_on_login_id", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
