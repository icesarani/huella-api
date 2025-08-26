# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts '🌱 Seeding Argentina geographic data...'

# Create Buenos Aires Province
puts 'Creating Buenos Aires province...'
buenos_aires = Province.find_or_initialize_by(indec_code: '06')
buenos_aires.assign_attributes(
  name: 'Buenos Aires',
  iso_code: 'AR-B'
)
buenos_aires.save!

puts 'Creating Buenos Aires localities...'

# Buenos Aires localities with INDEC codes (sample of major localities)
localities_data = [
  { indec_code: '06001010000', name: 'La Plata', category: :city },
  { indec_code: '06270070000', name: 'Mar del Plata', category: :city },
  { indec_code: '06840010000', name: 'Tandil', category: :city },
  { indec_code: '06028010000', name: 'Bahía Blanca', category: :city },
  { indec_code: '06105020000', name: 'Azul', category: :city },
  { indec_code: '06189080000', name: 'Campana', category: :city },
  { indec_code: '06371010000', name: 'Junín', category: :city },
  { indec_code: '06410010000', name: 'Luján', category: :city },
  { indec_code: '06515020000', name: 'Mercedes', category: :city },
  { indec_code: '06539010000', name: 'Morón', category: :city },
  { indec_code: '06560080000', name: 'Necochea', category: :city },
  { indec_code: '06595030000', name: 'Olavarría', category: :city },
  { indec_code: '06630010000', name: 'Pergamino', category: :city },
  { indec_code: '06658010000', name: 'Quilmes', category: :city },
  { indec_code: '06682010000', name: 'San Nicolás de los Arroyos', category: :city },
  { indec_code: '06756010000', name: 'Tres Arroyos', category: :city },
  { indec_code: '06274010000', name: 'Matanza', category: :simple_locality },
  { indec_code: '06441010000', name: 'Lomas de Zamora', category: :simple_locality },
  { indec_code: '06364010000', name: 'General San Martín', category: :simple_locality },
  { indec_code: '06021020000', name: 'Avellaneda', category: :simple_locality },
  { indec_code: '06077010000', name: 'Lanús', category: :simple_locality },
  { indec_code: '06805010000', name: 'Tigre', category: :simple_locality },
  { indec_code: '06252010000', name: 'Malvinas Argentinas', category: :simple_locality },
  { indec_code: '06392010000', name: 'José C. Paz', category: :simple_locality },
  { indec_code: '06154010000', name: 'Berazategui', category: :simple_locality },
  { indec_code: '06301010000', name: 'Esteban Echeverría', category: :simple_locality },
  { indec_code: '06427010000', name: 'Merlo', category: :simple_locality },
  { indec_code: '06315010000', name: 'Florencio Varela', category: :simple_locality },
  { indec_code: '06049010000', name: 'Almirante Brown', category: :simple_locality },
  { indec_code: '06389010000', name: 'Ituzaingó', category: :simple_locality },
  { indec_code: '06168020000', name: 'Brandsen', category: :simple_locality },
  { indec_code: '06245010000', name: 'Magdalena', category: :simple_locality },
  { indec_code: '06063010000', name: 'Berisso', category: :simple_locality },
  { indec_code: '06302020000', name: 'Ensenada', category: :simple_locality },
  { indec_code: '06259020000', name: 'Marcos Paz', category: :simple_locality },
  { indec_code: '06266010000', name: 'General Las Heras', category: :simple_locality },
  { indec_code: '06161010000', name: 'Bolívar', category: :simple_locality },
  { indec_code: '06196010000', name: 'Cañuelas', category: :simple_locality },
  { indec_code: '06210020000', name: 'Castelli', category: :simple_locality },
  { indec_code: '06237010000', name: 'Dolores', category: :simple_locality },
  { indec_code: '06350010000', name: 'General Pueyrredón', category: :simple_locality },
  { indec_code: '06385010000', name: 'Coronel de Marina Leonardo Rosales', category: :simple_locality },
  { indec_code: '06448010000', name: 'Lobos', category: :simple_locality },
  { indec_code: '06455010000', name: 'Monte', category: :simple_locality },
  { indec_code: '06469010000', name: 'Navarro', category: :simple_locality },
  { indec_code: '06511020000', name: 'Roque Pérez', category: :simple_locality },
  { indec_code: '06518010000', name: 'Saladillo', category: :simple_locality },
  { indec_code: '06525010000', name: 'San Vicente', category: :simple_locality },
  { indec_code: '06126010000', name: 'Balcarce', category: :simple_locality },
  { indec_code: '06343010000', name: 'General Alvarado', category: :simple_locality },
  { indec_code: '06455080000', name: 'Villa Gesell', category: :simple_locality },
  { indec_code: '06028080000', name: 'Monte Hermoso', category: :simple_locality }
]

localities_data.each do |locality_data|
  locality = Locality.find_or_initialize_by(indec_code: locality_data[:indec_code])
  locality.assign_attributes(
    name: locality_data[:name],
    category: locality_data[:category],
    province: buenos_aires
  )
  locality.save!
  print '.'
end

puts "\n✅ Successfully seeded #{localities_data.length} localities for Buenos Aires province!"
puts "📊 Total provinces: #{Province.count}"
puts "📊 Total localities: #{Locality.count}"
