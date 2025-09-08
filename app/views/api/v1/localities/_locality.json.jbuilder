# frozen_string_literal: true

json.id locality.id
json.name locality.name
json.indec_code locality.indec_code
json.category locality.category
json.created_at locality.created_at
json.updated_at locality.updated_at

# Include province information (without back-reference to localities to prevent circular reference)
if locality.province.present?
  json.province do
    json.partial! 'api/v1/provinces/province', province: locality.province
  end
else
  json.province nil
end
