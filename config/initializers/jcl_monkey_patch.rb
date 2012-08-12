# coding: utf-8

# Comme son nom l'indique, ce fichier sert à rajouter des méthodes à des modules
# et des classes de Rails



module ActiveRecord
  class Base
    

   
    def self.use_main_connection
      # FIXME utiliser une fonction de Rails plutôt que le database construit
      Rails.logger.info "début de use_main_connection : connecté à à #{connection_config}"
      case Rails.env
    when "development"
      establish_connection :development
    when "production"
      establish_connection :production
    end
    # Pour test on ne fait rien car changer de connection percute la logique de rspec
    # qui se déroule dans une transaction
    Rails.logger.info "appel de use_main connection : connexion à #{connection_config}"
      
    end

    def self.use_org_connection(db_name)
      Rails.logger.info "Connection à la base #{db_name}"
      
      establish_connection(
        :adapter => "sqlite3",
        :database  => "db/#{Rails.env}/organisms/#{db_name}.sqlite3")
      
    end


  end
end
