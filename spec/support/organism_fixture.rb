# coding: utf-8

# Module regroupant des méthodes pour générer les éléments minimaux d'organisation
# A utiliser en mettant include OrganismFixture dans la fichier spec ou on utilisera la méthode
module OrganismFixture

  def create_user
    ActiveRecord::Base.use_main_connection
    
    if User.count > 0
    Rails.logger.debug "Effacement de #{User.count} utilisateurs avant de recréer quidam"
      User.find(:all).each {|u| u.destroy}
    end
    @cu =  User.create!(name:'quidam')
    r = @cu.rooms.new(user_id:@cu.id, database_name:'assotest1')
    r.save!
  end

  def login_as(name)
    visit '/'
    fill_in 'user_name', :with=>name
    click_button 'Entrée'
  end

  # crée un organisme, un income_book, un outcome_book, un exercice (period),
  # une nature. 
  def create_minimal_organism
    # DatabaseCleaner ne semble pas toujours appelé correctement.
    ActiveRecord::Base.use_org_connection('assotest1')
    if Organism.count > 0
      Rails.logger.debug "Effacement de #{Organism.count} organismes avant de recréer organism_minimal"
      Organism.find(:all).each {|o| o.destroy}
    end
    @o = Organism.create!(title: 'ASSO TEST', database_name:'assotest1')
    @ib = @o.income_books.first # les livres sont créés par un after_create
    @ob = @o.outcome_books.first
    @od = @o.od_books.first
    @p = Period.create!(:organism_id=>@o.id, start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year)
    @n = Nature.create!(name: 'Essai', period_id: @p.id, :income_outcome=>false)
    @ba = @o.bank_accounts.create!(name: 'DebiX', number: '123Z')
    @c=@o.cashes.create!(:name=>'Magasin')
  end

  def create_second_organism
    @cu.rooms.create!(database_name:'assotest2')
    @o2 = Organism.create!(title: 'ASSO TEST2', database_name:'assotest2')
  end

  # crée le nombre de lignes demandées pour le minimal organism avec
  # des valeurs par défaut
  def create_lines(number)
    number.times do |i|
     Line.create!(line_date: Date.today, credit:0, debit:(i+1),
        book_id: @ob.id, cash_id:@c.id, narration: "Ligne test #{i+1}",
       nature_id: @n.id, payment_mode: 'Espèces' )
    end
  end

#  def create_next_period(organism, period)
#    p = organism.periods.new(start_date: (period.close_date+1), close_date: (period.close_date + 1).end_of_year)
#    puts p.inspect
#    p.save!
#  end

  # crée n lignes de recettes de caisse
  def create_cash_lines(number, period, cash, credit = 9 )
    period_length = period.close_date - period.start_date
    book = period.organism.income_books.first
    number.times do |n|
      alea = period.start_date + rand(period_length)
     Line.create!(line_date: alea, credit: credit,
        cash_id: cash.id, book_id: book.id, narration: "Ligne test #{n}",
       nature_id: @n.id, payment_mode: 'Espèces' )
    end
  end

#  def clean_test_database
#    os = Organism.all
#    os.each {|oss| oss.destroy }
#    Organism.count.should == 0
#
#  end

end
