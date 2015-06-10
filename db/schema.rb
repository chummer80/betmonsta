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

ActiveRecord::Schema.define(version: 20150610080249) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bets", force: :cascade do |t|
    t.datetime "match_time"
    t.string   "sport"
    t.string   "home_team"
    t.string   "away_team"
    t.boolean  "home_picked"
    t.float    "spread"
    t.integer  "odds"
    t.float    "risk_amount"
    t.datetime "result_time"
    t.string   "result"
    t.float    "resulting_balance"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "bets", ["user_id"], name: "index_bets_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password_digest"
    t.float    "balance"
    t.float    "max_balance"
    t.float    "ten_day_profit"
    t.float    "thirty_day_profit"
    t.float    "total_profit"
    t.boolean  "admin"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "remember_digest"
  end

  add_foreign_key "bets", "users"
end
