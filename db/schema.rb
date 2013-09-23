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

ActiveRecord::Schema.define(version: 20130915025106) do

  create_table "def_votes", force: true do |t|
    t.integer "user_id"
    t.integer "listword_def_id"
  end

  create_table "favorites", force: true do |t|
    t.integer "user_id"
    t.integer "list_id"
  end

  create_table "list_votes", force: true do |t|
    t.integer "user_id"
    t.integer "list_id"
    t.boolean "is_up"
  end

  create_table "list_words", force: true do |t|
    t.integer "list_id"
    t.integer "word_id"
  end

  create_table "lists", force: true do |t|
    t.integer "user_id"
    t.string  "name"
    t.integer "points"
    t.text    "description"
    t.boolean "public"
  end

  create_table "listword_defs", force: true do |t|
    t.integer "list_word_id"
    t.string  "definition"
    t.integer "points"
  end

  create_table "users", force: true do |t|
    t.string "username"
    t.string "password"
  end

  create_table "words", force: true do |t|
    t.string "word"
    t.string "first_def"
    t.text   "definition"
  end

end
