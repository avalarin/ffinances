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

ActiveRecord::Schema.define(version: 20140922151728) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: true do |t|
    t.string   "key"
    t.string   "display_name"
    t.integer  "owner_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "books", ["key"], name: "index_books_on_key", unique: true, using: :btree

  create_table "books_currencies", force: true do |t|
    t.integer "book_id"
    t.integer "currency_id"
  end

  create_table "books_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "book_id"
  end

  create_table "countries", force: true do |t|
    t.string "code"
    t.string "name"
  end

  add_index "countries", ["code"], name: "index_countries_on_code", unique: true, using: :btree

  create_table "countries_currencies", force: true do |t|
    t.integer "country_id"
    t.integer "currency_id"
  end

  create_table "currencies", force: true do |t|
    t.string "code"
    t.string "symbol"
    t.string "name"
    t.string "global_name"
  end

  add_index "currencies", ["code"], name: "index_currencies_on_code", unique: true, using: :btree

  create_table "currency_rates", force: true do |t|
    t.integer  "base_currency_id"
    t.integer  "target_currency_id"
    t.decimal  "value"
    t.datetime "date"
  end

  add_index "currency_rates", ["base_currency_id", "target_currency_id"], name: "index_currency_rates_on_base_currency_id_and_target_currency_id", unique: true, using: :btree

  create_table "operations", force: true do |t|
    t.integer "transaction_id"
    t.integer "wallet_id"
    t.integer "currency_id"
    t.decimal "currency_rate"
    t.integer "product_id"
    t.integer "unit_id"
    t.decimal "count"
    t.decimal "amount"
    t.decimal "sum"
  end

  create_table "products", force: true do |t|
    t.integer "book_id"
    t.integer "unit_id"
    t.string  "display_name"
  end

  create_table "sessions", force: true do |t|
    t.uuid     "key"
    t.integer  "user_id"
    t.boolean  "persistent", default: false
    t.boolean  "closed",     default: false
    t.datetime "closed_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip"
    t.string   "user_agent"
  end

  add_index "sessions", ["key"], name: "index_sessions_on_key", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.integer "book_id"
    t.string  "text"
  end

  add_index "tags", ["text"], name: "index_tags_on_text", using: :btree

  create_table "tags_transactions", force: true do |t|
    t.integer "transaction_id"
    t.integer "tag_id"
  end

  create_table "transactions", force: true do |t|
    t.integer  "book_id"
    t.integer  "creator_user_id"
    t.string   "description"
    t.string   "transaction_type"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", force: true do |t|
    t.json    "names"
    t.integer "decimals"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "display_name"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "approved",            default: false
    t.boolean  "locked",              default: false
    t.string   "roles"
    t.datetime "last_login_at"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wallet_types", force: true do |t|
    t.string "display_name"
    t.string "image_name"
  end

  create_table "wallets", force: true do |t|
    t.string   "key"
    t.string   "display_name"
    t.integer  "book_id"
    t.integer  "owner_user_id"
    t.integer  "currency_id"
    t.string   "type_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wallets", ["key"], name: "index_wallets_on_key", unique: true, using: :btree

end
