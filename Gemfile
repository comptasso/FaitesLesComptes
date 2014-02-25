source 'http://rubygems.org'
ruby "2.0.0"


gem 'rails', '3.2.17'
gem 'rack', '1.4.5'
# gem 'therubyracer' execjs sous windows
gem 'simple_form', "~> 2.1.0"
# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'acts_as_list', '0.1.9'
gem 'acts_as_tree', "~>1.4"
gem 'prawn', "~> 0.12"
gem 'prawn_rails', "0.0.11"
gem 'haml-rails', "~>0.3"
gem 'pg'
gem 'browser', '0.1.6' # utilisé pour détecter la version du navigateur (source github.com/fnando/browser)
gem 'apartment' # pour la gestion des schemas
gem 'devise' # pour l'authentification

gem 'delayed_job_active_record'
gem 'unicorn'
gem 'rack-timeout' # coneil de heroku - utilisé par le fichier intializers/timeout.rb
gem 'routing_concerns'  # Voir le gem sur github (permet de simplifier l'écriture des routes)
# TODO à retirer lors du passage à Rails 4

gem 'adherent' #, :path=>'../../Adherent'
gem 'sass'
gem 'coffee-script'


group :production, :staging do
  gem 'rails_12factor' 
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.2.0"
  gem 'coffee-rails', "~> 3.2.0"
  gem 'uglifier', "1.3.0"
  # gem 'twitter-bootstrap-rails'
end

gem 'jquery-rails', "2.1.4"



# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem 'simplecov', :require => false, :group => :test

group :development, :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'rspec-rails', '~>  2.0'

  gem 'spork-rails'
  gem 'launchy'
  gem 'daemons' # mis en place pour pouvoir lancer les Delayed::Job dans la console
  gem 'selenium-webdriver', '>= 2.39'
  gem 'capybara', '2.2.1'
  # gem 'capybara-webkit'
  gem 'email_spec'
  


end