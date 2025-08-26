# frozen_string_literal: true

class CreateProvinces < ActiveRecord::Migration[8.0]
  def change
    create_table :provinces do |t|
      t.string :indec_code
      t.string :name
      t.string :iso_code

      t.timestamps
    end
    add_index :provinces, :indec_code, unique: true
  end
end
