source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'addressable'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.4', '>= 6.1.4.1'
# PostgreSQL database
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
gem 'hiredis'
# ActiveJob manager
gem 'resque'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # only needed for MacOS and Ruby 3.0
  #gem 'sassc', github: 'sass/sassc-ruby', branch: 'master'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'spree', '~>4.3.0' # core and API
gem 'spree_frontend' # Rails storefront (optional)
gem 'spree_backend' # Rails admin panel (optional)
gem 'spree_emails' # transactional emails (optional)
gem 'spree_sample' # dummy data like products, taxons, etc
gem 'spree_auth_devise', '~> 4.3' # Devise integration (optional)
gem 'spree_gateway', '~> 3.9' # payment gateways eg. Stripe, Braintree (optional)
gem 'spree_i18n', '~> 5.0' # translation files (optional) 

gem 'spree_uuid','~> 0.0.2', git: 'https://github.com/webgem-jpl/spree_uuid.git'
gem 'spree_sale_channel', git: 'https://github.com/webgem-jpl/spree_sale_channel.git'
