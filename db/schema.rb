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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120524084108) do

  create_table "level_user_links", :force => true do |t|
    t.integer  "user_id"
    t.integer  "level_id"
    t.text     "uncompressed_path"
    t.text     "compressed_path"
    t.integer  "pushes"
    t.integer  "moves"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "levels", :force => true do |t|
    t.integer  "pack_id"
    t.string   "name"
    t.integer  "width"
    t.integer  "height"
    t.string   "copyright"
    t.text     "grid"
    t.text     "grid_with_floor"
    t.integer  "boxes_number"
    t.integer  "goals_number"
    t.integer  "pusher_pos_m"
    t.integer  "pusher_pos_n"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "packs", :force => true do |t|
    t.string   "name"
    t.string   "file_name"
    t.text     "description"
    t.string   "email"
    t.string   "url"
    t.string   "copyright"
    t.integer  "max_width"
    t.integer  "max_height"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "user_user_links", :force => true do |t|
    t.integer  "user_id",    :limit => 8
    t.integer  "friend_id",  :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "user_user_links", ["friend_id"], :name => "index_user_user_links_on_friend_id"
  add_index "user_user_links", ["user_id"], :name => "index_user_user_links_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "picture"
    t.string   "gender"
    t.string   "locale"
    t.integer  "f_id",           :limit => 8
    t.string   "f_token"
    t.string   "f_first_name"
    t.string   "f_middle_name"
    t.string   "f_last_name"
    t.string   "f_username"
    t.string   "f_link"
    t.integer  "f_timezone"
    t.datetime "f_updated_time"
    t.boolean  "f_verified"
    t.boolean  "f_expires"
    t.datetime "f_expires_at"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "users", ["f_id"], :name => "index_users_on_f_id", :unique => true

end
