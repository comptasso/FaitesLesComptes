# coding: utf-8

# Module regroupant des méthodes pour générer les éléments minimaux d'organisation
# A utiliser en mettant include OrganismFixture dans la fichier spec ou on utilisera la méthode
module OrganismFixture

  # crée un organisme, un income_book, un outcome_book, un exercice (period),
  # une nature. 
  def create_minimal_organism
    @o = Organism.create!(title: 'test_line')
    @ib = IncomeBook.create!(organism_id: @o.id, title: 'Recettes')
    @ob = OutcomeBook.create!(organism_id:@o.id, title: "Dépenses")
    @p = Period.create!(:organism_id=>@o.id, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31))
    @n = Nature.create!(name: 'Essai', period_id: @p.id)
    @ba = @o.bank_accounts.create!(name: '124578ZA')
    
  end

end
