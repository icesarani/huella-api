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

ActiveRecord::Schema[8.0].define(version: 2025_09_07_013103) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "certification_status", ["created", "assigned", "executed", "canceled", "rejected"]
  create_enum "work_schedule_time", ["none", "morning", "afternoon", "both"]

  create_table "blockchain_wallets", force: :cascade do |t|
    t.string "address"
    t.string "mnemonic_phrase"
    t.string "private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_blockchain_wallets_on_address", unique: true
  end

  create_table "certification_requests", force: :cascade do |t|
    t.enum "status", default: "created", null: false, enum_type: "certification_status"
    t.string "address"
    t.bigint "locality_id", null: false
    t.bigint "vet_profile_id"
    t.bigint "producer_profile_id", null: false
    t.date "scheduled_date", null: false
    t.integer "intended_animal_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locality_id"], name: "index_certification_requests_on_locality_id"
    t.index ["producer_profile_id"], name: "index_certification_requests_on_producer_profile_id"
    t.index ["vet_profile_id"], name: "index_certification_requests_on_vet_profile_id"
  end

  create_table "jwt_allowlists", force: :cascade do |t|
    t.string "jti"
    t.string "aud"
    t.datetime "exp"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_allowlists_on_jti"
    t.index ["user_id"], name: "index_jwt_allowlists_on_user_id"
  end

  create_table "localities", force: :cascade do |t|
    t.string "indec_code"
    t.string "name"
    t.string "category"
    t.bigint "province_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["indec_code"], name: "index_localities_on_indec_code", unique: true
    t.index ["province_id"], name: "index_localities_on_province_id"
  end

  create_table "producer_profiles", force: :cascade do |t|
    t.string "cuig_number", null: false
    t.string "renspa_number", null: false
    t.string "identity_card", null: false
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.bigint "blockchain_wallet_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blockchain_wallet_id"], name: "index_producer_profiles_on_blockchain_wallet_id", unique: true
    t.index ["cuig_number"], name: "index_producer_profiles_on_cuig_number", unique: true
    t.index ["identity_card"], name: "index_producer_profiles_on_identity_card", unique: true
    t.index ["renspa_number"], name: "index_producer_profiles_on_renspa_number", unique: true
    t.index ["user_id"], name: "index_producer_profiles_on_user_id", unique: true
  end

  create_table "provinces", force: :cascade do |t|
    t.string "indec_code"
    t.string "name"
    t.string "iso_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["indec_code"], name: "index_provinces_on_indec_code", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vet_profiles", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "identity_card", null: false
    t.string "license_number", null: false
    t.bigint "user_id", null: false
    t.bigint "blockchain_wallet_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blockchain_wallet_id"], name: "index_vet_profiles_on_blockchain_wallet_id", unique: true
    t.index ["identity_card"], name: "index_vet_profiles_on_identity_card", unique: true
    t.index ["license_number"], name: "index_vet_profiles_on_license_number", unique: true
    t.index ["user_id"], name: "index_vet_profiles_on_user_id", unique: true
  end

  create_table "vet_service_areas", force: :cascade do |t|
    t.bigint "vet_profile_id", null: false
    t.bigint "locality_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locality_id"], name: "index_vet_service_areas_on_locality_id"
    t.index ["vet_profile_id"], name: "index_vet_service_areas_on_vet_profile_id"
  end

  create_table "vet_work_schedules", force: :cascade do |t|
    t.bigint "vet_profile_id", null: false
    t.enum "monday", default: "none", null: false, enum_type: "work_schedule_time"
    t.enum "tuesday", default: "none", null: false, enum_type: "work_schedule_time"
    t.enum "wednesday", default: "none", null: false, enum_type: "work_schedule_time"
    t.enum "thursday", default: "none", null: false, enum_type: "work_schedule_time"
    t.enum "friday", default: "none", null: false, enum_type: "work_schedule_time"
    t.enum "saturday", default: "none", null: false, enum_type: "work_schedule_time"
    t.enum "sunday", default: "none", null: false, enum_type: "work_schedule_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vet_profile_id"], name: "index_vet_work_schedules_on_vet_profile_id", unique: true
  end

  add_foreign_key "certification_requests", "localities"
  add_foreign_key "certification_requests", "producer_profiles"
  add_foreign_key "certification_requests", "vet_profiles"
  add_foreign_key "jwt_allowlists", "users"
  add_foreign_key "localities", "provinces"
  add_foreign_key "producer_profiles", "blockchain_wallets"
  add_foreign_key "producer_profiles", "users"
  add_foreign_key "vet_profiles", "blockchain_wallets"
  add_foreign_key "vet_profiles", "users"
  add_foreign_key "vet_service_areas", "localities"
  add_foreign_key "vet_service_areas", "vet_profiles"
  add_foreign_key "vet_work_schedules", "vet_profiles"
end
