source 'https://rubygems.org'

gem 'rails',   '3.2.12'
gem "jax",     '3.0.0.rc2'
gem 'jasmine', '1.3.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem 'json'
gem 'omniauth-facebook', '1.4.0' # because of this in 1.4.1 : https://github.com/mkdynamic/omniauth-facebook/issues/73
gem 'koala'
gem 'nokogiri'
gem 'capistrano'
gem 'madmimi'
gem 'delayed_job_active_record'
gem 'daemons' # for delayed job
gem 'sitemap_generator'
gem 'httparty'

# graphs
gem 'groupdate'
gem 'chartkick'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
end

gem 'jquery-rails'
gem 'therubyracer'  # Exec js code in ruby
gem 'libv8'

# Development tools
group :development do
  gem 'thin'
  gem 'quiet_assets'
  gem 'query_reviewer'
end

# Production/deployment tools
group :production do
  gem 'unicorn'
  gem 'airbrake'
  gem 'whenever',    :require => false
  gem 'backup',      :require => false
  gem 'dropbox-sdk', :require => false
end
