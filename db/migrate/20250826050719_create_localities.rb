# frozen_string_literal: true

class CreateLocalities < ActiveRecord::Migration[8.0]
  def change
    create_table :localities do |t|
      t.string :indec_code
      t.string :name
      t.string :category
      t.references :province, null: false, foreign_key: true

      t.timestamps
    end
    add_index :localities, :indec_code, unique: true
  end
end
