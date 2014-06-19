# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

FileObject.create(name: 'root', parent_directory_id: 0, object_mode: 1)
FileObject.create(name: 'ゴミ箱', parent_directory_id: 1, object_mode: 2)
