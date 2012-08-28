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

ActiveRecord::Schema.define(:version => 20120809164120) do

  create_table "accounts", :force => true do |t|
    t.string   "number"
    t.string   "title"
    t.boolean  "used",       :default => true
    t.integer  "period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "archives", :force => true do |t|
    t.integer  "organism_id", :null => false
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.date     "date"
  end

  create_table "bank_extract_lines_lines", :id => false, :force => true do |t|
    t.integer "bank_extract_line_id"
    t.integer "line_id"
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
    t.string   "comment"
  end

  create_table "check_deposits", :force => true do |t|
    t.integer  "bank_account_id"
    t.date     "deposit_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bank_extract_line_id"
  end

  create_table "destinations", :force => true do |t|
    t.string   "name"
    t.integer  "organism_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "income_outcome", :default => false
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
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "ref"
    t.string   "check_number"
  end

  create_table "natures", :force => true do |t|
    t.string   "name"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "income_outcome", :default => false
    t.integer  "period_id"
    t.integer  "account_id"
  end

  create_table "organisms", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "database_name"
  end

  create_table "periods", :force => true do |t|
    t.date     "start_date"
    t.date     "close_date"
    t.integer  "organism_id"
    t.boolean  "open",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rooms", :force => true do |t|
    t.integer  "user_id"
    t.string   "database_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "transfers", :force => true do |t|
    t.date     "date"
    t.string   "narration"
    t.integer  "debitable_id"
    t.string   "debitable_type"
    t.integer  "creditable_id"
    t.string   "creditable_type"
    t.integer  "organism_id"
    t.decimal  "amount",          :precision => 2, :scale => 10
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
