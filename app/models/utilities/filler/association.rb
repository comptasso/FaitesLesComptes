module Utilities
  module Filler
    class Association < Utilities::Filler::Organism

      def remplit_destinations
        @org.destinations.create(name:'Non affecté', sector_id:@sect.id)
        @org.destinations.create(name:'Adhérents', sector_id:@sect.id)
      end
    end
  end
end
