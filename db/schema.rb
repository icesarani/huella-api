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

ActiveRecord::Schema[8.0].define(version: 2025_08_26_050000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "blockchain_wallets", force: :cascade do |t|
    t.string "address"
    t.string "mnemonic_phrase"
    t.string "private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_blockchain_wallets_on_address", unique: true
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

  add_foreign_key "producer_profiles", "blockchain_wallets"
  add_foreign_key "producer_profiles", "users"
  add_foreign_key "vet_profiles", "blockchain_wallets"
  add_foreign_key "vet_profiles", "users"
end
