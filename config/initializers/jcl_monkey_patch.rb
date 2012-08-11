# coding: utf-8

# Comme son nom l'indique, ce fichier sert à rajouter des méthodes à des modules
# et des classes de Rails

module ActiveRecord
  class Base
    

    def self.use_main_connection
      # FIXME utiliser une fonction de Rails plutôt que le database construit
      Rails.logger.info 'Connection à la base principale'
      establish_connection(
        :adapter => "sqlite3",
        :database  => "db/development.sqlite3")
      end

    def self.use_org_connection(db_name)
      Rails.logger.info "Connection à la base #{db_name}"
      establish_connection(
        :adapter => "sqlite3",
        :database  => "db/organisms/#{db_name}.sqlite3")
    end

  end
end
