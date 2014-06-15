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

  create_table "file_objects", force: true do |t|
    t.string   "name"
    t.integer  "parent_directory_id"
    t.integer  "object_mode"
    t.string   "hash_name",           limit: 64
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_objects", ["object_mode"], name: "index_file_objects_on_object_mode", using: :btree
  add_index "file_objects", ["parent_directory_id"], name: "index_file_objects_on_parent_directory_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "login_id",        limit: 32
    t.string   "password_digest", limit: 60
    t.string   "remember_token",  limit: 40
    t.boolean  "admin",                      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["login_id"], name: "index_users_on_login_id", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
