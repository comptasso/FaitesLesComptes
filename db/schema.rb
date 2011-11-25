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

ActiveRecord::Schema.define(:version => 20111123190507) do

  create_table "bank_extracts", :force => true do |t|
    t.integer  "listing_id"
    t.string   "reference"
    t.date     "du"
    t.date     "au"
    t.decimal  "begin_sold",   :precision => 2, :scale => 10, :default => 0.0
    t.decimal  "total_debit",  :precision => 2, :scale => 10, :default => 0.0
    t.decimal  "total_credit", :precision => 2, :scale => 10, :default => 0.0
    t.boolean  "validated",                                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "destinations", :force => true do |t|
    t.string   "name"
    t.integer  "organism_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lines", :force => true do |t|
    t.date     "line_date"
    t.string   "narration"
    t.integer  "nature_id"
    t.integer  "destination_id"
    t.decimal  "debit",           :default => 0.0
    t.decimal  "credit",          :default => 0.0
    t.integer  "listing_id"
    t.boolean  "locked",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "copied_id"
    t.boolean  "multiple",        :default => false
    t.integer  "bank_extract_id"
  end

  create_table "listings", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organism_id"
  end

  create_table "natures", :force => true do |t|
    t.string   "name"
    t.integer  "organism_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organisms", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
