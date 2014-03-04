
# Ce module est introduit dans Organism et Room pour éviter de dupliquer 
# les définitions de la gestion du timestamp lors de la création d'une Room
# 
# Si besoin, ne pas oublier de mettre attr_accessible :racine dans la modèle
#
module Utilities
  module Racine
  
  
    def racine
      database_name[/^[a-zA-Z0-9]*/] if database_name
    end
  
    def racine=(val)
      val ||= ''
      val.strip!
      self.database_name = val + '_' + Time.now.utc.strftime("%Y%m%d%H%M%S")
    end
  
  
  
  end

end
