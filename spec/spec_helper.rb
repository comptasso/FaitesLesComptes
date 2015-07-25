# -*- encoding : utf-8 -*-

require 'simplecov'
#SimpleCov.start do
#  add_filter "/config/" # on ne teste pas la couverture des fichiers config.
#end


  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'capybara/rails'
  require 'email_spec'
  require 'active_model/forbidden_attributes_protection'
  require File.expand_path(File.dirname(__FILE__) + '/support/organism_fixture_bis.rb')
  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.



  # pour les tests
    Delayed::Worker.delay_jobs = false

    RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  # Ajouté pour pouvoir utiliser les fixtures de Tenant
  # Ces fixtures ont été recopiés à partir du gem milia
  config.global_fixtures = [:tenants, :users, :tenants_users]
  config.include Devise::TestHelpers, :type => :controller

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
#  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  # config.order = "random"
    end
