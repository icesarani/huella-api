# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.3', '>= 7.1.3.2'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma'

# Pg is the Ruby interface to the PostgreSQL RDBMS
gem 'pg'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
# gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
# gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
# gem "stimulus-rails"

# Tailwind CSS is a utility-first CSS framework [https://github.com/rails/tailwindcss-rails]
gem 'tailwindcss-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Write annotations in models, fixture and factory files on migrations
gem 'annotate'

# Adds authentication
gem 'devise'

# Authorization Options
#
# gem "pundit"           # Authorization gem with policies scheme (Object-Oriented)
# gem "cancancan"        # Authorization gem with roles scheme

# Active Job Options
#
# gem "solid_queue"      # Postgres-backed queue
# gem "sidekiq"          # Redis-backed queue

# If you selected to use sidekiq please uncomment the redis gems
# Use Redis adapter to run Action Cable in production
# gem "redis"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Local Storage Management
# gem "minio"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mswin mswin64 mingw x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mswin mswin64 mingw x64_mingw]

  # Testing framework
  gem 'rspec-rails'

  # Generates fake data for various purposes
  gem 'faker'

  # Creates objects as test data for testing with factory classes
  gem 'factory_bot'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Gem to preview mails
  gem 'letter_opener'

  # Static code analyzer and formatter
  gem 'rubocop'

  # Static analysis security tool
  gem 'brakeman'

  # Yarddoc for documentacion
  gem 'yard'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
end
