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
#      config.global_fixtures = :all
    end
