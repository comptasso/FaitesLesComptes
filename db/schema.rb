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

ActiveRecord::Schema.define(:version => 20130110065905) do

  create_table "accounts", :force => true do |t|
    t.string   "number"
    t.string   "title"
    t.boolean  "used",             :default => true
    t.integer  "period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "accountable_type"
    t.integer  "accountable_id"
  end

  create_table "archives", :force => true do |t|
    t.integer  "organism_id", :null => false
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_accounts", :force => true do |t|
    t.string   "number"
    t.string   "bank_name"
    t.text     "comment"
    t.integer  "organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname"
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
    t.boolean  "locked",                                         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "begin_sold",      :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "total_debit",     :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "total_credit",    :precision => 10, :scale => 2, :default => 0.0
  end

  create_table "books", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organism_id"
    t.string   "type"
    t.string   "abbreviation"
  end

  create_table "cash_controls", :force => true do |t|
    t.integer  "cash_id"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "locked",                                    :default => false
    t.decimal  "amount",     :precision => 10, :scale => 2, :default => 0.0
  end

  create_table "cashes", :force => true do |t|
    t.integer  "organism_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
  end

  create_table "check_deposits", :force => true do |t|
    t.integer  "bank_account_id"
    t.date     "deposit_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bank_extract_line_id"
    t.integer  "writing_id"
  end

  create_table "compta_lines", :force => true do |t|
    t.integer  "nature_id"
    t.integer  "destination_id"
    t.boolean  "locked",                                          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_mode"
    t.integer  "check_deposit_id"
    t.string   "check_number"
    t.integer  "account_id"
    t.integer  "writing_id"
    t.decimal  "debit",            :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "credit",           :precision => 10, :scale => 2, :default => 0.0
  end

  add_index "compta_lines", ["account_id"], :name => "index_lines_on_account_id"

  create_table "destinations", :force => true do |t|
    t.string   "name"
    t.integer  "organism_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "income_outcome", :default => false
  end

  create_table "natures", :force => true do |t|
    t.string   "name"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "income_outcome", :default => false
    t.integer  "period_id"
    t.integer  "account_id"
    t.integer  "position"
  end

  create_table "nomenclatures", :force => true do |t|
    t.integer  "organism_id"
    t.text     "actif"
    t.text     "passif"
    t.text     "resultat"
    t.text     "benevolat"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "organisms", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "database_name"
    t.string   "status"
    t.string   "version"
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

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "writings", :force => true do |t|
    t.date     "date"
    t.string   "narration"
    t.string   "ref"
    t.integer  "book_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "type"
  end

end
