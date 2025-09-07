# frozen_string_literal: true

class AddLotCaracteristicsToCertificationRequest < ActiveRecord::Migration[8.0]
  def change
    create_enum :certification_request_declared_lot_weight, %w[skinny average heavy]
    create_enum :certification_request_declared_lot_age, %w[new_born young mature adult]
    create_enum :certification_request_declared_lot_health, %w[unhealthy common healthy]

    add_column :certification_requests, :declared_lot_weight, :enum,
               enum_type: :certification_request_declared_lot_weight, null: false
    add_column :certification_requests, :declared_lot_age, :enum, enum_type: :certification_request_declared_lot_age,
                                                                  null: false
    add_column :certification_requests, :declared_lot_health, :enum,
               enum_type: :certification_request_declared_lot_health, null: false
  end
end
