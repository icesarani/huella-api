# frozen_string_literal: true

class CreateVetServiceAreas < ActiveRecord::Migration[8.0]
  def change
    create_table :vet_service_areas do |t|
      t.references :vet_profile, null: false, foreign_key: true
      t.references :locality, null: false, foreign_key: true

      t.timestamps
    end
  end
end
