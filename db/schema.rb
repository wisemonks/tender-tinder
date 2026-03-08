# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_07_180000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "procurement_matches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "procurement_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["procurement_id"], name: "index_procurement_matches_on_procurement_id"
    t.index ["user_id", "procurement_id"], name: "index_procurement_matches_on_user_id_and_procurement_id", unique: true
    t.index ["user_id"], name: "index_procurement_matches_on_user_id"
  end

  create_table "procurement_stars", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "procurement_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["procurement_id"], name: "index_procurement_stars_on_procurement_id"
    t.index ["user_id", "procurement_id"], name: "index_procurement_stars_on_user_id_and_procurement_id", unique: true
    t.index ["user_id"], name: "index_procurement_stars_on_user_id"
  end

  create_table "procurements", force: :cascade do |t|
    t.string "authority_name"
    t.string "contract_duration"
    t.string "contract_type"
    t.string "cpc_category"
    t.text "cpv_codes"
    t.datetime "created_at", null: false
    t.datetime "deadline_date"
    t.text "description"
    t.decimal "estimated_value"
    t.string "evaluation_criteria"
    t.string "external_id"
    t.string "plan_reference"
    t.string "procedure_type"
    t.datetime "publication_date"
    t.text "raw_html"
    t.string "status"
    t.text "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["external_id"], name: "index_procurements_on_external_id", unique: true
    t.index ["publication_date"], name: "index_procurements_on_publication_date"
  end

  create_table "scraper_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "key", null: false
    t.string "setting_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.text "value"
    t.index ["user_id", "key"], name: "index_scraper_settings_on_user_id_and_key", unique: true
    t.index ["user_id"], name: "index_scraper_settings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "procurement_matches", "procurements"
  add_foreign_key "procurement_matches", "users"
  add_foreign_key "procurement_stars", "procurements"
  add_foreign_key "procurement_stars", "users"
  add_foreign_key "scraper_settings", "users"
end
