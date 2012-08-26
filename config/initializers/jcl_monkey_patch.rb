# coding: utf-8

# Comme son nom l'indique, ce fichier sert à rajouter des méthodes à des modules
# et des classes de Rails



module ActiveRecord
  class Base
     
    def self.use_main_connection
      Rails.logger.info "début de use_main_connection : connecté à à #{connection_config}"
      establish_connection Rails.env.to_sym
      Rails.logger.info "appel de use_main connection : connexion à #{connection_config}"
    end

    def self.use_org_connection(db_name)
      f_name  = "db/#{Rails.env}/organisms/#{db_name}.sqlite3"
      if File.exist? f_name
      Rails.logger.info "Connection à la base #{db_name}"
      establish_connection(
        :adapter => "sqlite3",
        :database  => f_name)
      return true
      else
        Rails.logger.warn "Tentative de connection à la base #{db_name}, fichier non trouvé"
        return false
      end
    end


  end
end
