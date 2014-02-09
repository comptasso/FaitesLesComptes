module Utilities
  module Filler
    class Entreprise < Utilities::Filler::Organism
      
      
      def remplit_destinations
        @org.destinations.create(name:'Non affecté', sector_id:@sect.id)
        @org.destinations.create(name:'Service numéro 1', sector_id:@sect.id) 
        @org.destinations.create(name:'Projet numéro 1', sector_id:@sect.id) 
      end
    end
  end
end