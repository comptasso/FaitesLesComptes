source 'http://rubygems.org'
ruby "2.0.0"


gem 'rails', '4.0.12'
# gem 'protected_attributes' # pour la transition vers Rails 4
gem 'rails-observers' # idem
gem 'actionpack-page_caching'
gem 'actionpack-action_caching' 

gem 'rack', '~>1.5'
# gem 'therubyracer' execjs sous windows
gem 'simple_form', "~> 3.1"
# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'acts_as_list', '0.6.0'
gem 'acts_as_tree', "~>1.4"
gem 'prawn', "~> 0.12"
gem 'prawn_rails', "0.0.11"
gem 'haml-rails', "~>0.3"
gem 'pg'
gem 'browser', '0.1.6' # utilisé pour détecter la version du navigateur (source github.com/fnando/browser)



gem 'apartment', '~> 0.24.3' # pour la gestion des schemas
gem 'devise' # pour l'authentification
gem "devise-async" # pour avoir l'envoi des mails en background
gem 'ofx' # pour la lecture des fichiers bancaires au format ofx

gem 'delayed_job_active_record', '= 4.0.2'
gem 'unicorn'
gem 'rack-timeout' # conseil de heroku - utilisé par le fichier intializers/timeout.rb
# gem 'routing_concerns'  # Voir le gem sur github (permet de simplifier l'écriture des routes)
# TODO à retirer lors du passage à Rails 4

gem 'adherent', '~>0.2.2'  # :path=>'../../Adherent' # #,

gem 'coffee-script'

gem 'best_in_place'


group :production, :staging do
  gem 'rails_12factor' 
end



  gem 'bootstrap-sass', '~> 3.3.1'
  
  gem 'autoprefixer-rails'
 
  # gem 'twitter-bootstrap-rails'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'


# correspondent à la version 1.11.1 de jQuery
gem 'jquery-rails', "3.1.2"
gem 'jquery-ui-rails', '5.0.2'


# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem 'simplecov', :require => false, :group => :test

group :development, :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'rspec-rails', '~>  2.14.0'

  gem 'spork-rails'
  gem 'launchy'
  gem 'daemons' # mis en place pour pouvoir lancer les Delayed::Job dans la console
  gem 'selenium-webdriver', '= 2.45.0.dev2'
  gem 'capybara', '2.4.4'
  # gem 'capybara-webkit'
  gem 'email_spec'
  


end