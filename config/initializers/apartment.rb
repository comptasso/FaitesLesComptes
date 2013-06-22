# coding: utf-8


# méthodes ajoutées par jcl 
module Apartment
  module Database

    #    pour pouvoir utiliser Apartment::Database.process sans difficulté
    # lorsqu'on veut lire dans la base principale.
    # Pour sqlite, on garde la logique de Rails qui est que la base principale est donnée par le
    # fichier database.yml et est development.sqlite3 pour l'environnement development, ou
    # production.sqlite3 pour l'environnement production.
    #
    # Pour postgresql qui fonctionne avec une logique de schémas, on utilise donc public pour la
    # base principale.
    #
    def default_db
      case ActiveRecord::Base.connection_config[:adapter]
      when 'sqlite3'
        Rails.env
      when 'postgresql'
        'public'
      end
    end

    # indique si une base existe
    def db_exist?(db_name)
      result = false
      current = Apartment::Database.current
      result = true if current == db_name
      Apartment::Database.switch(db_name)
      result = true
    rescue  Apartment::SchemaNotFound, Apartment::DatabaseNotFound =>e
      Rails.logger.warn "Tentative de connection à la base inexistante #{db_name}"
      result = false
    ensure
      Apartment::Database.switch(current)
      return result
    end




  end
end



Apartment.configure do |config|
  config.excluded_models = ['User', 'Room']
  if Rails.env == 'test'
    #   config.database_names = Dir.entries('db/test').map {|db| db[/(\w*).sqlite3/]; $1}.reject {|db| db == nil}
    config.database_names = ['assotest1', 'assotest2']
  else
    config.database_names = lambda { Room.select('database_name').map {|r| r.database_name}}
  end
  
  config.prepend_environment = false
end

