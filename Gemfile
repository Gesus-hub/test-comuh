source "https://rubygems.org"

ruby "3.4.7"

# Rails standard gems
gem "bootsnap", require: false
gem "puma", ">= 5.0"
gem "rails", "~> 8.1.2"
gem "tzinfo-data", platforms: %i[windows jruby]

# Database
gem "pg", "~> 1.1"

# Frontend / Assets
gem "importmap-rails"
gem "propshaft"
gem "stimulus-rails"
gem "turbo-rails"

# App
gem "faraday"
gem "haml-rails"

group :development do
  gem "rubocop-rails-omakase", require: false
  gem "web-console"
end

group :development, :test do
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "dotenv-rails"
  gem "rspec-rails"
  gem "simplecov", require: false
end

group :test do
  gem "factory_bot_rails"
end
