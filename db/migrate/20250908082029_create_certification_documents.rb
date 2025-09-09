# frozen_string_literal: true

class CreateCertificationDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :certification_documents do |t|
      t.references :cattle_certification, null: false, foreign_key: true, index: { unique: true }
      t.string :pdf_hash, null: false
      t.references :blockchain_transaction, null: false, foreign_key: true
      t.string :filename, null: false

      t.timestamps
    end

    add_index :certification_documents, :pdf_hash, unique: true
  end
end
