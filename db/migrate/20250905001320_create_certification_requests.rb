# frozen_string_literal: true

class CreateCertificationRequests < ActiveRecord::Migration[8.0]
  def change
    create_enum :certification_status, %w[created assigned executed canceled rejected]

    create_table :certification_requests do |t|
      t.enum :status, enum_type: :certification_status, null: false, default: 'created'
      t.string :address
      t.references :locality, null: false, foreign_key: true
      t.references :vet_profile, foreign_key: true, null: true
      t.references :producer_profile, null: false, foreign_key: true
      t.date :scheduled_date, null: false
      t.integer :intended_animal_group

      t.timestamps
    end
  end
end
