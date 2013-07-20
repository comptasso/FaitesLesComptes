# coding: utf-8


# méthodes ajoutées par jcl 
module Apartment
  class JclError < StandardError; end

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
      list_schemas.include?(db_name)
    end

    def list_schemas
      Apartment.connection.execute('SELECT DISTINCT SCHEMANAME FROM PG_STAT_USER_TABLES').map {|row| row['schemaname']}
    end

    # Cette méthode rename_schema n'est utile que pour Psotgres
    # elle doit être appelée par Room.after_save dans le cas ou database_name a été modifié.
    #
    # Cette méthode trouve son intérêt dans la problématique de la création et restauration
    # d'archive, permettant de modifier le schema d'une base existante avant de restaurer la suavegarde.
    #
    def rename_schema(old_name, new_name)
      # inutile de vérifier que ce nom est disponible car cette méthode est intégrée dans un after_save de Room
      # et donc dans une transaction
      # current_db = Apartment::Database.current
      return if old_name == new_name
      raise Apartment::JclError unless ActiveRecord::Base.connection_config[:adapter] == 'postgresql'
      raise Apartment::JclError, :message=>'On ne peut renommer le schema public' if old_name == 'public'
      Apartment::Database.switch('public')
      Apartment.connection.execute(%{ALTER SCHEMA "#{old_name}" RENAME TO "#{new_name}"})
    rescue  Apartment::SchemaNotFound, Apartment::JclError
      puts "Erreur dans rename_schema #{old_name} en #{new_name}"
      Rails.logger.warn "Erreur dans rename_schema #{old_name} en #{new_name}"
    end




  end
end



Apartment.configure do |config|
  config.excluded_models = ['User', 'Room']
  if Rails.env == 'test'
    # config.database_names = ['assotest1', 'assotest2']
    config.database_names = lambda { Room.select('database_name').map {|r| r.database_name}}
  else
    config.database_names = lambda { Room.select('database_name').map {|r| r.database_name}}
  end
  
  config.prepend_environment = false
end

