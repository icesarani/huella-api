# frozen_string_literal: true

class ReplaceLotEnumsWithIntegers < ActiveRecord::Migration[8.0]
  def up
    # First clear any existing data to avoid NOT NULL constraint issues
    execute 'DELETE FROM certification_requests'

    # Remove existing enum columns
    remove_column :certification_requests, :declared_lot_weight, :enum
    remove_column :certification_requests, :declared_lot_age, :enum
    remove_column :certification_requests, :declared_lot_health, :enum

    # Drop the enum types
    drop_enum :certification_request_declared_lot_weight
    drop_enum :certification_request_declared_lot_age
    drop_enum :certification_request_declared_lot_health

    # Add new integer columns
    add_column :certification_requests, :declared_lot_weight, :integer, null: false
    add_column :certification_requests, :declared_lot_age, :integer, null: false
  end

  def down
    # Remove integer columns
    remove_column :certification_requests, :declared_lot_weight, :integer
    remove_column :certification_requests, :declared_lot_age, :integer

    # Recreate enum types
    create_enum :certification_request_declared_lot_weight, %w[skinny average heavy]
    create_enum :certification_request_declared_lot_age, %w[new_born young mature adult]
    create_enum :certification_request_declared_lot_health, %w[unhealthy common healthy]

    # Add enum columns back
    add_column :certification_requests, :declared_lot_weight, :enum,
               enum_type: :certification_request_declared_lot_weight, null: false
    add_column :certification_requests, :declared_lot_age, :enum,
               enum_type: :certification_request_declared_lot_age, null: false
    add_column :certification_requests, :declared_lot_health, :enum,
               enum_type: :certification_request_declared_lot_health, null: false
  end
end
