source 'http://rubygems.org'

gem 'rails', '3.2.13'
gem 'rack', '1.4.5'
# gem 'therubyracer' execjs sous windows
gem 'simple_form', "~> 2.0.1"
# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3', '1.3.7'
gem 'acts_as_list', '0.1.9'
gem 'prawn', "~> 0.12"
gem 'prawn_rails', "0.0.11"
gem 'haml-rails', "~>0.3"
gem 'browser', '0.1.6' # utilisé pour détecter la version du navigateur (source github.com/fnando/browser)




# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.2.0"
  gem 'coffee-rails', "~> 3.2.0"
  gem 'uglifier', "1.3.0"
  # gem 'twitter-bootstrap-rails'
end

gem 'jquery-rails', "2.1.4"

# Use unicorn as the web server
# gem 'mongrel'


group :ocra do
  # le gem ocra a été patché sur la partie Windows (voir start.rb)
  # il est donc important de garder la même version
  gem 'ocra', '1.3.1'
end

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'simplecov', :require => false, :group => :test

group :development, :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'rspec-rails', '2.8.1'
  gem 'watchr'
  gem 'spork-rails'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'selenium-webdriver', '>= 2.31'
  gem 'capybara', '1.1.2'
  


end