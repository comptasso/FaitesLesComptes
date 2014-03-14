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

ActiveRecord::Schema.define(:version => 20140314191226) do

  create_table "accounts", :force => true do |t|
    t.string   "number"
    t.string   "title"
    t.boolean  "used",             :default => true
    t.integer  "period_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "accountable_type"
    t.integer  "accountable_id"
  end

  create_table "adherent_adhesions", :force => true do |t|
    t.date     "from_date"
    t.date     "to_date"
    t.decimal  "amount",     :precision => 10, :scale => 2
    t.integer  "member_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "adherent_adhesions", ["member_id"], :name => "index_adherent_adhesions_on_member_id"

  create_table "adherent_bridges", :force => true do |t|
    t.integer  "organism_id"
    t.integer  "bank_account_id"
    t.integer  "cash_id"
    t.integer  "destination_id"
    t.string   "nature_name"
    t.integer  "income_book_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "adherent_coords", :force => true do |t|
    t.string   "mail"
    t.string   "tel"
    t.string   "gsm"
    t.string   "office"
    t.text     "address"
    t.string   "zip"
    t.string   "city"
    t.integer  "member_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "adherent_members", :force => true do |t|
    t.string   "number"
    t.string   "name"
    t.string   "forname"
    t.date     "birthdate"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "organism_id"
  end

  create_table "adherent_payments", :force => true do |t|
    t.date     "date"
    t.decimal  "amount",     :precision => 10, :scale => 2
    t.string   "mode"
    t.integer  "member_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "adherent_payments", ["member_id"], :name => "index_adherent_payments_on_member_id"

  create_table "adherent_reglements", :force => true do |t|
    t.decimal  "amount",      :precision => 10, :scale => 2
    t.integer  "adhesion_id"
    t.integer  "payment_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "adherent_reglements", ["adhesion_id"], :name => "index_adherent_reglements_on_adhesion_id"
  add_index "adherent_reglements", ["payment_id"], :name => "index_adherent_reglements_on_payment_id"

  create_table "bank_accounts", :force => true do |t|
    t.string   "number"
    t.string   "bank_name"
    t.text     "comment"
    t.integer  "organism_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "nickname"
    t.integer  "sector_id"
  end

  create_table "bank_extract_lines", :force => true do |t|
    t.integer  "position"
    t.integer  "bank_extract_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "compta_line_id"
  end

  add_index "bank_extract_lines", ["compta_line_id"], :name => "index_bank_extract_lines_on_compta_line_id"

  create_table "bank_extracts", :force => true do |t|
    t.integer  "bank_account_id"
    t.string   "reference"
    t.date     "begin_date"
    t.date     "end_date"
    t.boolean  "locked",                                         :default => false
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.decimal  "begin_sold",      :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "total_debit",     :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "total_credit",    :precision => 10, :scale => 2, :default => 0.0
  end

  create_table "books", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "type"
    t.string   "abbreviation"
    t.integer  "organism_id"
    t.integer  "sector_id"
  end

  create_table "cash_controls", :force => true do |t|
    t.integer  "cash_id"
    t.date     "date"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.boolean  "locked",                                    :default => false
    t.decimal  "amount",     :precision => 10, :scale => 2, :default => 0.0
  end

  create_table "cashes", :force => true do |t|
    t.integer  "organism_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "comment"
    t.integer  "sector_id"
  end

  create_table "check_deposits", :force => true do |t|
    t.integer  "bank_account_id"
    t.date     "deposit_date"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "bank_extract_line_id"
    t.integer  "writing_id"
  end

  create_table "compta_lines", :force => true do |t|
    t.integer  "nature_id"
    t.integer  "destination_id"
    t.boolean  "locked",                                          :default => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.string   "payment_mode"
    t.integer  "check_deposit_id"
    t.string   "check_number"
    t.integer  "account_id"
    t.integer  "writing_id"
    t.decimal  "debit",            :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "credit",           :precision => 10, :scale => 2, :default => 0.0
  end

  add_index "compta_lines", ["account_id"], :name => "index_lines_on_account_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "destinations", :force => true do |t|
    t.string   "name"
    t.integer  "organism_id"
    t.text     "comment"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "sector_id"
  end

  create_table "export_pdfs", :force => true do |t|
    t.binary   "content"
    t.string   "exportable_type"
    t.integer  "exportable_id"
    t.string   "status"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "folios", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "sens"
    t.integer  "nomenclature_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "holders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "room_id"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "masks", :force => true do |t|
    t.string   "title"
    t.text     "comment"
    t.integer  "organism_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "book_id"
    t.string   "nature_name"
    t.string   "narration"
    t.integer  "destination_id"
    t.string   "mode"
    t.string   "counterpart"
    t.string   "ref"
    t.decimal  "amount"
  end

  add_index "masks", ["organism_id"], :name => "index_masks_on_organism_id"

  create_table "natures", :force => true do |t|
    t.string   "name"
    t.text     "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "period_id"
    t.integer  "account_id"
    t.integer  "position"
    t.integer  "book_id"
  end

  create_table "nomenclatures", :force => true do |t|
    t.integer  "organism_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "organisms", :force => true do |t|
    t.string   "title"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "database_name"
    t.string   "status"
    t.string   "version"
    t.string   "comment"
  end

  create_table "periods", :force => true do |t|
    t.date     "start_date"
    t.date     "close_date"
    t.integer  "organism_id"
    t.boolean  "open",        :default => true
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "rooms", :force => true do |t|
    t.string   "database_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "rubriks", :force => true do |t|
    t.string   "name"
    t.string   "numeros"
    t.integer  "parent_id"
    t.integer  "folio_id"
    t.integer  "position"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_leaf",    :default => false
  end

  create_table "sectors", :force => true do |t|
    t.integer  "organism_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "day"
    t.integer  "mask_id"
    t.date     "end_date"
    t.string   "title"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "permanent",  :default => false
  end

  add_index "subscriptions", ["mask_id"], :name => "index_subscriptions_on_mask_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "email",                  :default => "",         :null => false
    t.string   "encrypted_password",     :default => "",         :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "role",                   :default => "standard"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "writings", :force => true do |t|
    t.date     "date"
    t.string   "narration"
    t.string   "ref"
    t.integer  "book_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "type"
    t.integer  "bridge_id"
    t.string   "bridge_type"
    t.integer  "continuous_id"
    t.date     "locked_at"
    t.date     "ref_date"
  end

end
