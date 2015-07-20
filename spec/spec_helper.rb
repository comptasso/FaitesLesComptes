# -*- encoding : utf-8 -*-

require 'simplecov'
#SimpleCov.start do
#  add_filter "/config/" # on ne teste pas la couverture des fichiers config.
#end

  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'capybara/rails'
  require 'email_spec'
  require 'active_model/forbidden_attributes_protection'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.

    # pour les tests
    Delayed::Worker.delay_jobs = false


