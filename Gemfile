source 'https://rubygems.org'

gem 'rails', '3.2.3'
gem "jax", "~> 2.0.0"

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem 'json'
gem 'omniauth-facebook'
gem "koala", "~> 1.4.1"
gem "nokogiri", "~> 1.5.2"   # xml parser
gem 'thin'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# Development tools
group :development do
  gem 'heroku'
  gem 'quiet_assets'

  # use "rake app:deploy"
  if ENV['MY_BUNDLE_ENV'] == "development"
    gem 'therubyracer'  # Exec js code in ruby
  end
end

# Production/deployment tools
group :production do
  # use "rake app:deploy"
  if ENV['MY_BUNDLE_ENV'] == "production"
    gem 'therubyracer-heroku', '0.8.1.pre3'
  end
  
  gem 'pg'
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'
