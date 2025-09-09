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

ActiveRecord::Schema[8.0].define(version: 2025_09_08_082029) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "cattle_breed", ["angus", "hereford", "brahman", "charolais", "limousin", "simmental", "holstein", "jersey", "shorthorn", "other"]
  create_enum "cattle_category", ["unweaned_calf", "weaned_heifer", "weaned_steer"]
  create_enum "certification_status", ["created", "assigned", "executed", "canceled", "rejected"]
  create_enum "dental_chronology", ["milk_incisors_first_medians", "milk_second_medians", "milk_corners", "leveling_incisors", "leveling_first_medians", "leveling_second_medians", "leveling_corners", "permanent_incisors", "permanent_first_medians", "permanent_second_medians", "permanent_corners", "full_dentition"]
  create_enum "gender", ["male", "female"]
  create_enum "pregnancy_diagnosis_method", ["palpation", "ultrasound", "blood_test"]
  create_enum "request_certification_scheduled_time", ["morning", "afternoon"]
  create_enum "work_schedule_time", ["none", "morning", "afternoon", "both"]

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blockchain_transactions", force: :cascade do |t|
    t.string "transaction_hash", null: false
    t.bigint "block_number"
    t.string "status", default: "pending", null: false
    t.bigint "gas_used"
    t.string "network", null: false
    t.string "contract_address", null: false
    t.text "error_message"
    t.json "raw_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["network", "contract_address"], name: "index_blockchain_transactions_on_network_and_contract_address"
    t.index ["status"], name: "index_blockchain_transactions_on_status"
    t.index ["transaction_hash"], name: "index_blockchain_transactions_on_transaction_hash", unique: true
  end

  create_table "blockchain_wallets", force: :cascade do |t|
    t.string "address"
    t.string "mnemonic_phrase"
    t.string "private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_blockchain_wallets_on_address", unique: true
  end

  create_table "cattle_certifications", force: :cascade do |t|
    t.bigint "certified_lot_id", null: false
    t.string "cuig_code"
    t.string "alternative_code"
    t.enum "gender", null: false, enum_type: "gender"
    t.enum "category", null: false, enum_type: "cattle_category"
    t.enum "dental_chronology", enum_type: "dental_chronology"
    t.integer "estimated_weight"
    t.boolean "pregnant"
    t.enum "pregnancy_diagnosis_method", enum_type: "pregnancy_diagnosis_method"
    t.tstzrange "pregnancy_service_range"
    t.integer "corporal_condition"
    t.string "brucellosis_diagnosis"
    t.string "comments"
    t.jsonb "geolocation_points", default: {"lat"=>0, "lng"=>0}
    t.datetime "data_taken_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["certified_lot_id"], name: "index_cattle_certifications_on_certified_lot_id"
  end

  create_table "certification_documents", force: :cascade do |t|
    t.bigint "cattle_certification_id", null: false
    t.string "pdf_hash", null: false
    t.bigint "blockchain_transaction_id", null: false
    t.string "filename", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blockchain_transaction_id"], name: "index_certification_documents_on_blockchain_transaction_id"
    t.index ["cattle_certification_id"], name: "index_certification_documents_on_cattle_certification_id", unique: true
    t.index ["pdf_hash"], name: "index_certification_documents_on_pdf_hash", unique: true
  end

  create_table "certification_requests", force: :cascade do |t|
    t.enum "status", default: "created", null: false, enum_type: "certification_status"
    t.string "address"
    t.bigint "locality_id", null: false
    t.bigint "vet_profile_id"
    t.bigint "producer_profile_id", null: false
    t.date "scheduled_date"
    t.integer "intended_animal_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "scheduled_time", enum_type: "request_certification_scheduled_time"
    t.tstzrange "preferred_time_range", null: false
    t.enum "cattle_breed", null: false, enum_type: "cattle_breed"
    t.integer "declared_lot_weight", null: false
    t.integer "declared_lot_age", null: false
    t.index ["locality_id"], name: "index_certification_requests_on_locality_id"
    t.index ["producer_profile_id"], name: "index_certification_requests_on_producer_profile_id"
    t.index ["vet_profile_id"], name: "index_certification_requests_on_vet_profile_id"
  end

  create_table "certified_lots", force: :cascade do |t|
    t.bigint "certification_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["certification_request_id"], name: "index_certified_lots_on_certification_request_id"
  end

  create_table "file_uploads", force: :cascade do |t|
    t.bigint "certification_request_id", null: false
    t.string "ai_analyzed_age"
    t.string "ai_analyzed_weight"
    t.string "ai_analyzed_breed"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["certification_request_id"], name: "index_file_uploads_on_certification_request_id", unique: true
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cattle_certifications", "certified_lots"
  add_foreign_key "certification_documents", "blockchain_transactions"
  add_foreign_key "certification_documents", "cattle_certifications"
  add_foreign_key "certification_requests", "localities"
  add_foreign_key "certification_requests", "producer_profiles"
  add_foreign_key "certification_requests", "vet_profiles"
  add_foreign_key "certified_lots", "certification_requests"
  add_foreign_key "file_uploads", "certification_requests"
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
