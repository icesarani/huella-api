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

puts "\n🩺 Creating veterinarian with comprehensive schedule..."

# Create blockchain wallet for the vet
vet_blockchain_wallet = BlockchainWallet.find_or_create_by!(
  address: '0x1234567890abcdef1234567890abcdef12345678'
) do |wallet|
  wallet.mnemonic_phrase = 'vet seed twelve words for blockchain wallet access and security purposes'
  wallet.private_key = "0x#{SecureRandom.hex(32)}"
end

# Create user account for the veterinarian with vet profile
vet_user = User.find_or_create_by!(email: 'vet@huellarural.com') do |user|
  user.password = 'VetPassword123!'
  user.password_confirmation = 'VetPassword123!'
  user.build_vet_profile(
    first_name: 'Dr. María Elena',
    last_name: 'Rodríguez Veterinaria',
    identity_card: '20345678901',
    license_number: 'VET001234',
    blockchain_wallet: vet_blockchain_wallet
  )
end

# Get the vet profile (either newly created or existing)
if vet_user.vet_profile
  vet_profile = vet_user.vet_profile

  puts "✅ Created veterinarian profile: #{vet_profile.first_name} #{vet_profile.last_name}"

  # Define 3 fixed localities for this veterinarian
  target_localities = [
    'La Plata',      # Capital city - good for central location
    'Tandil',        # Mid-sized city with rural surroundings
    'Azul'           # Another rural/agricultural area
  ]

  puts '📍 Adding service areas for 3 localities...'

  target_localities.each do |locality_name|
    locality = Locality.find_by(name: locality_name)
    if locality
      VetServiceArea.find_or_create_by!(
        vet_profile: vet_profile,
        locality: locality
      )
      puts "  ✓ Added service area: #{locality_name}"
    else
      puts "  ⚠️  Locality '#{locality_name}' not found - skipping"
    end
  end

  # Create comprehensive work schedule - available most of the time
  work_schedule = VetWorkSchedule.find_or_create_by!(vet_profile: vet_profile) do |schedule|
    schedule.monday = 'both'      # Full day Monday
    schedule.tuesday = 'both'     # Full day Tuesday
    schedule.wednesday = 'both'   # Full day Wednesday
    schedule.thursday = 'morning' # Thursday mornings only
    schedule.friday = 'both'      # Full day Friday
    schedule.saturday = 'morning' # Saturday mornings only
    schedule.sunday = 'none'      # Sundays off
  end

  puts '📅 Created work schedule:'
  puts '  Monday: Full day (morning + afternoon)'
  puts '  Tuesday: Full day (morning + afternoon)'
  puts '  Wednesday: Full day (morning + afternoon)'
  puts '  Thursday: Morning only'
  puts '  Friday: Full day (morning + afternoon)'
  puts '  Saturday: Morning only'
  puts '  Sunday: Not available'

  puts '✅ Veterinarian setup complete!'
  puts '📧 Login email: vet@huellarural.com'
  puts '🔑 Password: VetPassword123!'
  puts "🏥 Service areas: #{target_localities.join(', ')}"
  puts "⏰ Working days: #{work_schedule.working_days.count} days per week"
else
  puts 'ℹ️  Veterinarian profile already exists - skipping creation'
end

puts "\n🐄 Creating sample producer for testing..."

# Create blockchain wallet for the producer
producer_blockchain_wallet = BlockchainWallet.find_or_create_by!(
  address: '0xabcdef1234567890abcdef1234567890abcdef12'
) do |wallet|
  wallet.mnemonic_phrase = 'producer farm cattle blockchain secure wallet test development environment setup'
  wallet.private_key = "0x#{SecureRandom.hex(32)}"
end

# Create user account for the producer with producer profile
producer_user = User.find_or_create_by!(email: 'producer@huellarural.com') do |user|
  user.password = 'ProducerPass123!'
  user.password_confirmation = 'ProducerPass123!'
  user.build_producer_profile(
    name: 'Estancia San Miguel',
    cuig_number: 'CUIG123456789',
    renspa_number: 'RENSPA987654',
    identity_card: '20123456789',
    blockchain_wallet: producer_blockchain_wallet
  )
end

# Get the producer profile (either newly created or existing)
if producer_user.producer_profile
  producer_profile = producer_user.producer_profile

  puts "✅ Created producer profile: #{producer_profile.name}"
  puts '📧 Login email: producer@huellarural.com'
  puts '🔑 Password: ProducerPass123!'
  puts "🏭 CUIG: #{producer_profile.cuig_number}"
  puts "🏭 RENSPA: #{producer_profile.renspa_number}"
else
  puts 'ℹ️  Producer profile already exists - skipping creation'
end

puts "\n🎯 Seed data summary:"
puts "📊 Provinces: #{Province.count}"
puts "📊 Localities: #{Locality.count}"
puts "👨‍⚕️ Veterinarians: #{VetProfile.count}"
puts "🧑‍🌾 Producers: #{ProducerProfile.count}"
puts "📍 Vet service areas: #{VetServiceArea.count}"
puts "⏰ Work schedules: #{VetWorkSchedule.count}"
puts "\n✨ Seeding completed successfully!"
