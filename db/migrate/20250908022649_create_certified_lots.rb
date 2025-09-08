# frozen_string_literal: true

class CreateCertifiedLots < ActiveRecord::Migration[8.0]
  def change
    create_table :certified_lots do |t|
      t.references :certification_request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
