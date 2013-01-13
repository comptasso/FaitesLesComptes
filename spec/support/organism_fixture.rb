# coding: utf-8

# Module regroupant des méthodes pour générer les éléments minimaux d'organisation
# A utiliser en mettant include OrganismFixture dans la fichier spec ou on utilisera la méthode
module OrganismFixture

  def create_user
    if User.count > 0
    Rails.logger.debug "Effacement de #{User.count} utilisateurs avant de recréer quidam"
      User.find(:all).each {|u| u.destroy}
    end
    @cu =  User.create!(name:'quidam')
    r = @cu.rooms.new(user_id:@cu.id, database_name:'assotest1')
    r.save!
  end

 # utile pour les requests qui nécessitent d'être identifié
 # il faut appeler avant create_user (pour pouvoir utiliser login_as('quidam')
  def login_as(name)
    visit '/'
    fill_in 'user_name', :with=>name
    click_button 'Entrée'
  end

  def create_organism
    clean_test_base
    @o = Organism.create!(title: 'ASSO TEST', database_name:'assotest1', status:'Association')
  end

  # crée un organisme, un income_book, un outcome_book, un exercice (period),
  # une nature. 
  def create_minimal_organism
    clean_test_base
   
    @o = Organism.create!(title: 'ASSO TEST', database_name:'assotest1', status:'Association')
    @ib = @o.income_books.first # les livres sont créés par un after_create
    @ob = @o.outcome_books.first
    @od = @o.od_books.first
    @p = Period.create!(:organism_id=>@o.id, start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year)
    @n = Nature.create!(name: 'Essai', period_id: @p.id, :income_outcome=>false)
    @rec = Nature.create!(name:'Recettes', period_id:@p.id, income_outcome:true)
    @ba = @o.bank_accounts.first
    @ba.update_attributes(bank_name:'DebiX', number:'123Z', nickname:'Compte courant')
    @c=@o.cashes.first
    @c.update_attribute(:name, 'Magasin'); @c.save;
    @baca = @ba.current_account(@p) # pour baca pour BankAccount Current Account
    @caca = @c.current_account(@p) # pour caca pour CashAccount Current Account
    @income_account = @o.accounts.classe_7.first
    @outcome_account = @o.accounts.classe_6.first
  end

  # DatabaseCleaner ne semble pas toujours appelé correctement.
  def clean_test_base
     ActiveRecord::Base.establish_connection('assotest1')
    if Organism.count > 0
      Rails.logger.debug "Effacement de #{Organism.count} organismes avant de recréer organism_minimal"
      Organism.find(:all).each {|o| o.destroy}
    end
  end

  def create_in_out_writing(montant=99, payment='Virement')
    if payment == 'Chèque'
      acc_id = @p.rem_check_account.id
    else
      acc_id = @baca.id
    end
    ecriture = @ib.in_out_writings.create!({date:Date.today, narration:'ligne créée par la méthode create_in_out_writing',
      :compta_lines_attributes=>{'0'=>{account_id:@income_account.id, nature:@n, credit:montant, payment_mode:payment},
        '1'=>{account_id:acc_id, debit:montant, payment_mode:payment}
      }
    })
    ecriture
  end

  def create_outcome_writing(montant=99, payment='Virement')
    ecriture = @ob.in_out_writings.create!({date:Date.today, narration:'ligne créée par la méthode create_outcome_writing',
      :compta_lines_attributes=>{'0'=>{account_id:@income_account.id, nature:@n, debit:montant, payment_mode:payment},
        '1'=>{account_id:@baca.id, credit:montant, payment_mode:payment}
      }
    })
     ecriture
  end

  def create_cash_income(montant = 59)
    ecriture = @ob.in_out_writings.create!({date:Date.today, narration:'ligne créée par la méthode create_cash_income',
      :compta_lines_attributes=>{'0'=>{account_id:@income_account.id, nature:@n, credit:montant, payment_mode:'Espèces'},
        '1'=>{account_id:@caca.id, debit:montant, payment_mode:'Espèces'}
      }
    })
     ecriture
  end

 
#  def create_first_line
#    @l1 = Line.create!(narration:'bel',counter_account_id:@baca.id,
#      line_date:Date.today, debit:0, credit:97, payment_mode:'Virement', book_id:@ob.id, nature_id:@n.id)
#  end
#
#  def create_second_line
#    @l2 = Line.create!(narration:'bel', counter_account_id:@baca.id,
#      line_date:Date.today, debit:0, credit:3, payment_mode:'Virement', book_id:@ob.id, nature_id:@n.id)
#  end

  def create_second_organism 
    @cu.rooms.create!(database_name:'assotest2')
    @o2 = Organism.create!(title: 'ASSO TEST2', database_name:'assotest2', status:'Entreprise') 
  end

  # crée le nombre de lignes demandées pour le minimal organism avec
  # des valeurs par défaut
  # UTILISE ENCORE LINE ET NON COMPTA LINE
#  def create_lines(number)
#    number.times do |i|
#     Line.create!(line_date: Date.today, credit:0, debit:(i+1),
#        book_id: @ob.id, cash_id:@c.id, narration: "Ligne test #{i+1}",
#       nature_id: @n.id, payment_mode: 'Espèces' )
#    end
#  end

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
     ComptaLine.create!(line_date: alea, credit: credit,
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
