# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Development admin user (idempotent).
if Rails.env.local?
  admin = User.find_or_initialize_by(email: "admin@example.com")
  admin.update!(name: "Admin", password: "password123", role: :admin) if admin.new_record?
  Rails.logger.info("Seeded admin user: #{admin.email}")

  [
    { name: "Sala Alfa", capacity: 6, description: "Sala pequena para reuniões rápidas." },
    { name: "Sala Beta", capacity: 12, description: "Sala média com projetor." },
    { name: "Sala Gama", capacity: 30, description: "Auditório para apresentações." }
  ].each do |attrs|
    Room.find_or_create_by!(name: attrs[:name]) do |room|
      room.capacity = attrs[:capacity]
      room.description = attrs[:description]
    end
  end
  Rails.logger.info("Seeded #{Room.count} rooms")
end
