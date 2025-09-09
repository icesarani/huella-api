# frozen_string_literal: true

json.array! certified_lots, partial: 'api/v1/certified_lots/certified_lot',
                            as: :certified_lot
