# coding: utf-8


# méthodes ajoutées par jcl 
module Apartment
  class JclError < StandardError; end

  module Database

    

    # Pour pouvoir utiliser Apartment::Database.process sans difficulté
    # lorsqu'on veut lire dans la base principale.
    #
    # Pour sqlite, on garde la logique de Rails qui est que la base principale est donnée par le
    # fichier database.yml et est development.sqlite3 pour l'environnement development, ou
    # production.sqlite3 pour l'environnement production.
    # 
    # TODO supprimer toute référence à sqlite3
    #
    # Pour postgresql qui fonctionne avec une logique de schémas, on utilise donc public pour la
    # base principale.
    # 
    # 
    # RAPPEL : les commandes ActiveRecord::Base.connection.current_database et 
    # current_schema permettent ... comme leur nom l'indique.
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
      raise Apartment::JclError unless ActiveRecord::Base.connection_config[:adapter] == 'postgresql'
      Apartment.connection.execute('SELECT DISTINCT SCHEMANAME FROM PG_STAT_USER_TABLES').map {|row| row['schemaname']}
    end

    # list_schemas_except_public renvoie la liste des schémas non public
    #
    # Si un bloc est fourni, le bloc est exécuté pour chaque membre de la liste
    def list_schemas_except_public
      ls =  list_schemas.reject {|schema| schema == 'public'}
      ls.each {|l| yield(l) if block_given?}
      ls
    end

    # Cette méthode rename_schema n'est utile que pour Postgres
    # elle doit être appelée par Room.after_save dans le cas ou database_name a été modifié puisque database_name
    # désigne le nom du schema.
    #
    # Cette méthode trouve son intérêt dans la problématique de la création et restauration
    # d'archive, permettant de modifier le schema d'une base existante avant de restaurer la sauvegarde.
    #
    # Actuellement la fonctionnalité d'archive a été retirée et cette méthode ne devrait donc pas être utilisée.
    #
    def rename_schema(old_name, new_name)
      # inutile de vérifier que ce nom est disponible car cette méthode est intégrée dans un after_save de Room
      # et donc dans une transaction
      # current_db = Apartment::Database.current
      return if old_name == new_name
      raise Apartment::JclError unless ActiveRecord::Base.connection_config[:adapter] == 'postgresql'
      raise Apartment::JclError  if old_name == 'public'
      raise Apartment::JclError, "#{new_name} existe déjà" if db_exist?(new_name)
      Apartment::Database.switch('public') # pour être certain de ne pas être sur le schéma old_name
      Apartment.connection.execute(%{ALTER SCHEMA "#{old_name}" RENAME TO "#{new_name}"})
    rescue  Apartment::SchemaNotFound, Apartment::JclError =>e
      Rails.logger.warn "Erreur dans rename_schema #{old_name} en #{new_name} - #{e.message}"
      return false
    end

    # utile dans les tests pour nettoyer les schémas devenus inutiles
    def drop_unused_schemas
      Apartment::Database.list_schemas_except_public do |schema|
        Apartment::Database.drop(schema) unless Room.find_by_database_name(schema)
      end
    end

    

    # Pour copier complètement un schéma
    def copy_schema(from_schema, to_schema)
      raise Apartment::SchemaNotFound, "#{from_schema} n'existe pas" unless db_exist?(from_schema)
      raise Apartment::JclError, "#{to_schema} n'existe pas" unless db_exist?(to_schema)

      tables = ActiveRecord::Base.connection.tables
      tables.reject! {|t| t == "schema_migrations"}
      tables.each {|t| copy_table(t, from_schema, to_schema)}
    rescue  Apartment::SchemaNotFound, Apartment::JclError =>e
      Rails.logger.warn "Erreur dans copy_table #{from_schema} en #{to_schema} - #{e.message}"
      return false
    end

   protected

    # copy_table recopie exactement les données de la table d un schéma vers un autre
    #
    # Cette méthode est utilisée pour créer un clone d'un schma existant
    #
    def copy_table(table_name, from_schema, to_schema)
      raise Apartment::SchemaNotFound, "#{from_schema} n'existe pas" unless db_exist?(from_schema)
      raise Apartment::JclError, "#{to_schema} n'existe pas" unless db_exist?(to_schema)

      Apartment.connection.execute(%{INSERT INTO #{to_schema}.#{table_name} SELECT * FROM #{from_schema}.#{table_name} })
      set_sequence(table_name, from_schema, to_schema)

    rescue  Apartment::SchemaNotFound, Apartment::JclError =>e
      Rails.logger.warn "Erreur dans copy_table #{table_name} #{from_schema} en #{to_schema} - #{e.message}"
      return false
    end


    def set_sequence(table_name, from_schema, to_schema)
      # on vérifie qu'il y a une colonne id
      return unless ActiveRecord::Base.connection.column_exists?("#{from_schema}.#{table_name}", 'id')

      # on vérifie si une séquence existe
      pgr = Apartment.connection.execute(%{select pg_get_serial_sequence('#{from_schema}.#{table_name}', 'id') })
      return if pgr.column_values(0).empty?
      schema_seq = pgr.column_values(0).first
      seq = schema_seq.split('.').last

      puts seq
      puts schema_seq
#      select setval('tenniscluba_20130725051741.books_id_seq', (select last_value FROM tenniscluba.books_id_seq));
      Apartment.connection.execute(%{SELECT setval('#{to_schema}.#{seq}', (SELECT last_value FROM #{schema_seq})) })
    end





  end
end


# Définit ls modèles qui font référence à la table commune
# ainsi que la méthode pour lister tous les schémas.
Apartment.configure do |config|
  config.excluded_models = ['User', 'Room', 'Delayed::Job']
  config.database_names = lambda { Apartment::Database.list_schemas_except_public }
  config.prepend_environment = false
end

