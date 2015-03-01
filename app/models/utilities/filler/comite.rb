module Utilities
  module Filler
    class Comite < Utilities::Filler::Organism
      
      def remplit_sectors
        # puts @org
        @org.sectors.create!(name:'Fonctionnement')
        @org.sectors.create!(name:'ASC')
        @fonc = @org.sectors.where('name = ?', 'Fonctionnement').first
        @asc = @org.sectors.where('name = ?', 'ASC').first
      end
      
      def remplit_books
        @org.income_books.create(abbreviation:'VEF', title:'Recettes fonctionnement', description:'Recettes fonctionnement', sector_id:@fonc.id)
        @org.outcome_books.create(abbreviation:'ACF', title:'Dépenses fonctionnement', description:'Dépenses fonctionnement', sector_id:@fonc.id)
        
        @org.income_books.create(abbreviation:'VEA', title:'Recettes ASC', description:'Recettes ASC', sector_id:@asc.id)
        @org.outcome_books.create(abbreviation:'ACA', title:'Dépenses ASC', description:'Dépenses ASC', sector_id:@asc.id)
        
        @org.od_books.create(abbreviation:'OD', :title=>'Opérations diverses', description:'Op.Diverses')
        @org.create_an_book(abbreviation:'AN', :title=>'A nouveau', description:'A nouveau')
      end
      
      
      def remplit_destinations
        @org.destinations.create(name:'ASC Non affecté', sector_id:@asc.id)
        @org.destinations.create(name:'ASC activité numéro 1', sector_id:@asc.id) 
        @org.destinations.create(name:'ASC activité numéro 2', sector_id:@asc.id)
        @org.destinations.create(name:'FONC général', sector_id:@fonc.id)        
      end
      
      def remplit_finances
        @org.cashes.create(name:'La Caisse ASC', sector_id:@asc.id)
        @org.cashes.create(name:'La Caisse fonctionnement', sector_id:@fonc.id)
        @org.bank_accounts.create(bank_name:'La Banque', number:'Numéro de Compte ASC', nickname:'Compte courant ASC', sector_id:@asc.id)
        @org.bank_accounts.create(bank_name:'La Banque', number:'Numéro de Compte fonctt', nickname:'Compte courant fonctionnement', sector_id:@fonc.id)
      end
    end
  end
end
