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

ActiveRecord::Schema.define(version: 20151114154028) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.string   "number"
    t.string   "title"
    t.boolean  "used",             default: true
    t.integer  "period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "accountable_type"
    t.integer  "accountable_id"
    t.integer  "sector_id"
    t.integer  "tenant_id"
  end

  add_index "accounts", ["tenant_id"], name: "index_accounts_on_tenant_id", using: :btree

  create_table "adherent_adhesions", force: true do |t|
    t.date     "from_date"
    t.date     "to_date"
    t.decimal  "amount",     precision: 10, scale: 2
    t.integer  "member_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "tenant_id"
  end

  add_index "adherent_adhesions", ["member_id"], name: "index_adherent_adhesions_on_member_id", using: :btree
  add_index "adherent_adhesions", ["tenant_id"], name: "index_adherent_adhesions_on_tenant_id", using: :btree

  create_table "adherent_bridges", force: true do |t|
    t.integer  "organism_id"
    t.integer  "bank_account_id"
    t.integer  "cash_id"
    t.integer  "destination_id"
    t.string   "nature_name"
    t.integer  "income_book_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "tenant_id"
  end

  add_index "adherent_bridges", ["tenant_id"], name: "index_adherent_bridges_on_tenant_id", using: :btree

  create_table "adherent_coords", force: true do |t|
    t.string   "mail"
    t.string   "tel"
    t.string   "gsm"
    t.string   "office"
    t.text     "address"
    t.string   "zip"
    t.string   "city"
    t.integer  "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "tenant_id"
  end

  add_index "adherent_coords", ["tenant_id"], name: "index_adherent_coords_on_tenant_id", using: :btree

  create_table "adherent_members", force: true do |t|
    t.string   "number"
    t.string   "name"
    t.string   "forname"
    t.date     "birthdate"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "organism_id"
    t.integer  "tenant_id"
  end

  add_index "adherent_members", ["tenant_id"], name: "index_adherent_members_on_tenant_id", using: :btree

  create_table "adherent_payments", force: true do |t|
    t.date     "date"
    t.decimal  "amount",     precision: 10, scale: 2
    t.string   "mode"
    t.integer  "member_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "comment"
    t.integer  "tenant_id"
  end

  add_index "adherent_payments", ["member_id"], name: "index_adherent_payments_on_member_id", using: :btree
  add_index "adherent_payments", ["tenant_id"], name: "index_adherent_payments_on_tenant_id", using: :btree

  create_table "adherent_reglements", force: true do |t|
    t.decimal  "amount",      precision: 10, scale: 2
    t.integer  "adhesion_id"
    t.integer  "payment_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "tenant_id"
  end

  add_index "adherent_reglements", ["adhesion_id"], name: "index_adherent_reglements_on_adhesion_id", using: :btree
  add_index "adherent_reglements", ["payment_id"], name: "index_adherent_reglements_on_payment_id", using: :btree
  add_index "adherent_reglements", ["tenant_id"], name: "index_adherent_reglements_on_tenant_id", using: :btree

  create_table "bank_accounts", force: true do |t|
    t.string   "number"
    t.string   "bank_name"
    t.text     "comment"
    t.integer  "organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname"
    t.integer  "sector_id"
    t.integer  "tenant_id"
  end

  add_index "bank_accounts", ["tenant_id"], name: "index_bank_accounts_on_tenant_id", using: :btree

  create_table "bank_extract_lines", force: true do |t|
    t.integer  "position"
    t.integer  "bank_extract_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "compta_line_id"
    t.integer  "tenant_id"
  end

  add_index "bank_extract_lines", ["compta_line_id"], name: "index_bank_extract_lines_on_compta_line_id", using: :btree
  add_index "bank_extract_lines", ["tenant_id"], name: "index_bank_extract_lines_on_tenant_id", using: :btree

  create_table "bank_extracts", force: true do |t|
    t.integer  "bank_account_id"
    t.string   "reference"
    t.date     "begin_date"
    t.date     "end_date"
    t.boolean  "locked",                                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "begin_sold",      precision: 10, scale: 2, default: 0.0
    t.decimal  "total_debit",     precision: 10, scale: 2, default: 0.0
    t.decimal  "total_credit",    precision: 10, scale: 2, default: 0.0
    t.integer  "tenant_id"
  end

  add_index "bank_extracts", ["tenant_id"], name: "index_bank_extracts_on_tenant_id", using: :btree

  create_table "books", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organism_id"
    t.string   "type"
    t.string   "abbreviation"
    t.integer  "sector_id"
    t.integer  "tenant_id"
  end

  add_index "books", ["tenant_id"], name: "index_books_on_tenant_id", using: :btree

  create_table "cash_controls", force: true do |t|
    t.integer  "cash_id"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "locked",                              default: false
    t.decimal  "amount",     precision: 10, scale: 2, default: 0.0
    t.integer  "tenant_id"
  end

  add_index "cash_controls", ["tenant_id"], name: "index_cash_controls_on_tenant_id", using: :btree

  create_table "cashes", force: true do |t|
    t.integer  "organism_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
    t.integer  "sector_id"
    t.integer  "tenant_id"
  end

  add_index "cashes", ["tenant_id"], name: "index_cashes_on_tenant_id", using: :btree

  create_table "check_deposits", force: true do |t|
    t.integer  "bank_account_id"
    t.date     "deposit_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bank_extract_line_id"
    t.integer  "writing_id"
    t.integer  "written_by"
    t.string   "user_ip"
    t.integer  "tenant_id"
  end

  add_index "check_deposits", ["tenant_id"], name: "index_check_deposits_on_tenant_id", using: :btree

  create_table "compta_lines", force: true do |t|
    t.integer  "nature_id"
    t.integer  "destination_id"
    t.boolean  "locked",                                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_mode"
    t.integer  "check_deposit_id"
    t.string   "check_number"
    t.integer  "account_id"
    t.integer  "writing_id"
    t.decimal  "debit",            precision: 10, scale: 2, default: 0.0
    t.decimal  "credit",           precision: 10, scale: 2, default: 0.0
    t.integer  "tenant_id"
  end

  add_index "compta_lines", ["account_id"], name: "index_lines_on_account_id", using: :btree
  add_index "compta_lines", ["tenant_id"], name: "index_compta_lines_on_tenant_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "destinations", force: true do |t|
    t.string   "name"
    t.integer  "organism_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sector_id"
    t.boolean  "used",        default: true
    t.integer  "tenant_id"
  end

  add_index "destinations", ["tenant_id"], name: "index_destinations_on_tenant_id", using: :btree

  create_table "export_pdfs", force: true do |t|
    t.binary   "content"
    t.string   "exportable_type"
    t.integer  "exportable_id"
    t.string   "status"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "tenant_id"
  end

  add_index "export_pdfs", ["tenant_id"], name: "index_export_pdfs_on_tenant_id", using: :btree

  create_table "flccloner", force: true do |t|
    t.string  "name"
    t.integer "old_id"
    t.integer "new_id"
    t.integer "old_org_id"
    t.integer "new_org_id"
  end

  create_table "folios", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "sens"
    t.integer  "nomenclature_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "sector_id"
    t.integer  "tenant_id"
  end

  add_index "folios", ["tenant_id"], name: "index_folios_on_tenant_id", using: :btree

  create_table "holders", force: true do |t|
    t.integer  "user_id"
    t.integer  "room_id"
    t.string   "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "tenant_id"
    t.integer  "organism_id"
  end

  add_index "holders", ["tenant_id"], name: "index_holders_on_tenant_id", using: :btree

  create_table "imported_bels", force: true do |t|
    t.integer  "position"
    t.date     "date"
    t.string   "narration"
    t.decimal  "debit",           precision: 10, scale: 2
    t.decimal  "credit",          precision: 10, scale: 2
    t.integer  "bank_account_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "cat"
    t.integer  "nature_id"
    t.string   "payment_mode"
    t.integer  "destination_id"
    t.string   "ref"
    t.integer  "writing_id"
    t.date     "writing_date"
    t.integer  "tenant_id"
  end

  add_index "imported_bels", ["tenant_id"], name: "index_imported_bels_on_tenant_id", using: :btree

  create_table "masks", force: true do |t|
    t.string   "title"
    t.text     "comment"
    t.integer  "organism_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "book_id"
    t.string   "nature_name"
    t.string   "narration"
    t.integer  "destination_id"
    t.string   "mode"
    t.string   "counterpart"
    t.string   "ref"
    t.decimal  "amount"
    t.integer  "tenant_id"
  end

  add_index "masks", ["organism_id"], name: "index_masks_on_organism_id", using: :btree
  add_index "masks", ["tenant_id"], name: "index_masks_on_tenant_id", using: :btree

  create_table "natures", force: true do |t|
    t.string   "name"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "period_id"
    t.integer  "account_id"
    t.integer  "position"
    t.integer  "book_id"
    t.integer  "tenant_id"
  end

  add_index "natures", ["tenant_id"], name: "index_natures_on_tenant_id", using: :btree

  create_table "nomenclatures", force: true do |t|
    t.integer  "organism_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "job_finished_at"
    t.integer  "tenant_id"
  end

  add_index "nomenclatures", ["tenant_id"], name: "index_nomenclatures_on_tenant_id", using: :btree

  create_table "organisms", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "database_name"
    t.string   "status"
    t.string   "version"
    t.string   "comment"
    t.string   "siren"
    t.string   "postcode"
    t.integer  "tenant_id"
  end

  add_index "organisms", ["tenant_id"], name: "index_organisms_on_tenant_id", using: :btree

  create_table "periods", force: true do |t|
    t.date     "start_date"
    t.date     "close_date"
    t.integer  "organism_id"
    t.boolean  "open",            default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "nomenclature_ok", default: false
    t.boolean  "prepared",        default: false
    t.integer  "tenant_id"
  end

  add_index "periods", ["tenant_id"], name: "index_periods_on_tenant_id", using: :btree

  create_table "rooms", force: true do |t|
    t.string   "database_name"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "tenant_id"
    t.integer  "new_org_id"
    t.boolean  "transformed",   default: false
  end

  add_index "rooms", ["tenant_id"], name: "index_rooms_on_tenant_id", using: :btree

  create_table "rubriks", force: true do |t|
    t.string   "name"
    t.string   "numeros"
    t.integer  "parent_id"
    t.integer  "folio_id"
    t.integer  "position"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.boolean  "is_leaf",                                default: false
    t.integer  "period_id"
    t.decimal  "brut",          precision: 10, scale: 2, default: 0.0
    t.decimal  "amortissement", precision: 10, scale: 2, default: 0.0
    t.decimal  "previous_net",  precision: 10, scale: 2, default: 0.0
    t.integer  "tenant_id"
  end

  add_index "rubriks", ["tenant_id"], name: "index_rubriks_on_tenant_id", using: :btree

  create_table "sectors", force: true do |t|
    t.integer  "organism_id"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "tenant_id"
  end

  add_index "sectors", ["tenant_id"], name: "index_sectors_on_tenant_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "subscriptions", force: true do |t|
    t.integer  "day"
    t.integer  "mask_id"
    t.date     "end_date"
    t.string   "title"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "permanent",  default: false
    t.integer  "tenant_id"
  end

  add_index "subscriptions", ["mask_id"], name: "index_subscriptions_on_mask_id", using: :btree
  add_index "subscriptions", ["tenant_id"], name: "index_subscriptions_on_tenant_id", using: :btree

  create_table "tenants", force: true do |t|
    t.integer  "tenant_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tenants", ["name"], name: "index_tenants_on_name", using: :btree
  add_index "tenants", ["tenant_id"], name: "index_tenants_on_tenant_id", using: :btree

  create_table "tenants_users", id: false, force: true do |t|
    t.integer "tenant_id", null: false
    t.integer "user_id",   null: false
  end

  add_index "tenants_users", ["tenant_id", "user_id"], name: "index_tenants_users_on_tenant_id_and_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                        default: "",         null: false
    t.string   "encrypted_password",           default: "",         null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "role",                         default: "standard"
    t.integer  "tenant_id"
    t.boolean  "skip_confirm_change_password", default: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "writings", force: true do |t|
    t.date     "date"
    t.string   "narration"
    t.string   "ref"
    t.integer  "book_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "type"
    t.integer  "bridge_id"
    t.string   "bridge_type"
    t.integer  "continuous_id"
    t.date     "locked_at"
    t.date     "ref_date"
    t.integer  "written_by"
    t.string   "user_ip"
    t.date     "date_piece"
    t.integer  "piece_number"
    t.integer  "tenant_id"
  end

  add_index "writings", ["date"], name: "index_writings_on_date", using: :btree
  add_index "writings", ["tenant_id"], name: "index_writings_on_tenant_id", using: :btree

end
