module Utilities
  module Filler
    # class de base utilisée pour créer les différents enregistrements
    # qui suivent la création d'un organisme.
    #
    # Des enfants viennent spécialiser ou surcharger les méthodes pour 
    # adapter les créations aux particularités des statuts
    class Organism
      
      def initialize(org)
        @org = org
      end
      
      def remplit
        remplit_sectors
        remplit_books
        remplit_finances
        remplit_destinations
        remplit_nomenclature
      end
      
      protected
      
      def remplit_sectors
        @org.sectors.create!(name:'Global')
        @sect = @org.sectors.first
      end
      
      def remplit_books 
        # les 4 livres
        Rails.logger.debug 'Création des livres par défaut'
        @org.income_books.create(abbreviation:'VE', title:'Recettes', description:'Recettes', sector_id:@sect.id)
        Rails.logger.debug  'création livre recettes'
        @org.outcome_books.create(abbreviation:'AC', title:'Dépenses', description:'Dépenses', sector_id:@sect.id)
        Rails.logger.debug 'creation livre dépenses'
        @org.od_books.create(abbreviation:'OD', :title=>'Opérations diverses', description:'Op.Diverses')
        Rails.logger.debug 'creation livre OD'
        @org.create_an_book(abbreviation:'AN', :title=>'A nouveau', description:'A nouveau')
      end
  
      def remplit_finances
        @org.cashes.create(name:'La Caisse', sector_id:@sect.id)
        Rails.logger.debug 'creation de la caisse par défaut'
        @org.bank_accounts.create(bank_name:'La Banque', number:'Le Numéro de Compte', nickname:'Compte courant', sector_id:@sect.id)
        Rails.logger.debug 'creation la banque par défaut'
      end
  
      def remplit_destinations
        @org.destinations.create(name:'Non affecté', sector_id:@sect.id)
        @org.destinations.create(name:'Activité principale', sector_id:@sect.id) 
      end
  
      def remplit_nomenclature 
        if @org.status
          path = File.join Rails.root, 'app', 'assets', 'parametres', @org.send(:status_class).downcase, 'nomenclature.yml'
          n = @org.create_nomenclature 
          n.read_and_fill_folios(path)
        end
      end
  
    end
  end
end
