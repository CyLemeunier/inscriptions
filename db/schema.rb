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

ActiveRecord::Schema.define(version: 20160925183324) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "players", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "licence"
    t.integer  "credit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registrations", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "tournament_id"
    t.string   "tableau1"
    t.string   "serie1"
    t.string   "tableau2"
    t.string   "serie2"
    t.string   "tableau3"
    t.string   "serie3"
    t.integer  "price"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "com1"
    t.string   "com2"
    t.string   "com3"
  end

  add_index "registrations", ["player_id"], name: "index_registrations_on_player_id", using: :btree
  add_index "registrations", ["tournament_id"], name: "index_registrations_on_tournament_id", using: :btree

  create_table "tournaments", force: :cascade do |t|
    t.string   "city"
    t.integer  "price1"
    t.integer  "price2"
    t.integer  "price3"
    t.boolean  "club"
    t.string   "convocations"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "serie"
    t.string   "tableau"
    t.date     "date"
    t.date     "date2"
    t.date     "deadline"
    t.text     "comment"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "amount"
    t.string   "reason"
    t.integer  "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "transactions", ["player_id"], name: "index_transactions_on_player_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "registrations", "players"
  add_foreign_key "registrations", "tournaments"
  add_foreign_key "transactions", "players"
end
