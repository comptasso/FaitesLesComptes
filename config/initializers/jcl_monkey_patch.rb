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

    

  end
end
