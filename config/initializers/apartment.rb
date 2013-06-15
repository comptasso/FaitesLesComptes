# coding: utf-8


# méthodes ajoutées par jcl pour pouvoir utiliser Apartment::Database.process sans difficulté
# lorsqu'on veut lire dans la base principale.
# Pour sqlite, on garde la logique de Rails qui est que la base principale est donnée par le
# fichier database.yml et est development.sqlite3 pour l'environnement development, ou
# production.sqlite3 pour l'environnement production.
#
# Pour postgresql qui fonctionne avec une logique de schémas, on utilise donc public pour la
# base principale.
#
module Apartment
  module Database
    def default_db
      case ActiveRecord::Base.connection_config[:adapter]
      when 'sqlite3'
         Rails.env
      when 'postgresql'
        'public'
      end
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

