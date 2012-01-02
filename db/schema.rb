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

ActiveRecord::Schema.define(:version => 20120102074450) do

  create_table "bank_accounts", :force => true do |t|
    t.string   "number"
    t.string   "name"
    t.text     "comment"
    t.text     "address"
    t.integer  "organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_extract_lines", :force => true do |t|
    t.integer  "position"
    t.integer  "bank_extract_id"
    t.integer  "line_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "check_deposit_id"
  end

  create_table "bank_extracts", :force => true do |t|
    t.integer  "bank_account_id"
    t.string   "reference"
    t.date     "begin_date"
    t.date     "end_date"
    t.decimal  "begin_sold",      :default => 0.0
    t.decimal  "total_debit",     :default => 0.0
    t.decimal  "total_credit",    :default => 0.0
    t.boolean  "locked",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "books", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organism_id"
    t.string   "type"
  end

  create_table "cash_controls", :force => true do |t|
    t.integer  "cash_id"
    t.decimal  "amount"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "locked",     :default => false
  end

  create_table "cashes", :force => true do |t|
    t.integer  "organism_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "check_deposits", :force => true do |t|
    t.integer  "bank_account_id"
    t.date     "deposit_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bank_extract_id"
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
    t.decimal  "debit",            :default => 0.0
    t.decimal  "credit",           :default => 0.0
    t.integer  "book_id"
    t.boolean  "locked",           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "copied_id"
    t.boolean  "multiple",         :default => false
    t.integer  "bank_extract_id"
    t.string   "payment_mode"
    t.integer  "check_deposit_id"
    t.integer  "cash_id"
    t.integer  "bank_account_id"
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

  create_table "periods", :force => true do |t|
    t.date     "start_date"
    t.date     "close_date"
    t.integer  "organism_id"
    t.boolean  "open",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
