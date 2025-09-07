# frozen_string_literal: true

class AddCattleBreedAndCreateFileUploads < ActiveRecord::Migration[8.0]
  def change
    # Create cattle breed enum
    create_enum :cattle_breed, %w[angus hereford brahman charolais limousin simmental holstein jersey shorthorn other]

    # Add cattle breed to certification requests
    add_column :certification_requests, :cattle_breed, :enum, enum_type: :cattle_breed, null: false

    # Create file uploads table
    create_table :file_uploads do |t|
      t.references :certification_request, null: false, foreign_key: true, index: { unique: true }
      t.string :ai_analyzed_age
      t.string :ai_analyzed_weight
      t.string :ai_analyzed_breed
      t.datetime :processed_at

      t.timestamps
    end
  end
end
