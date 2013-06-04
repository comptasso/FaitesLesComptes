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
    r = @cu.rooms.new(database_name:'assotest1')
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
    @p = @o.periods.create!(start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year)
    @n = @p.natures.create!(name: 'Essai', :income_outcome=>false)
    @rec = @p.natures.create!(name:'Recettes', income_outcome:true)
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
      Organism.all.each {|o| o.destroy}
    end
    Transfer.delete_all # on utilise delete_all car certains tests verrouillent
    # les écritures, lesquelles dès lors, ne peuvent plus être effacées
    Account.delete_all
    InOutWriting.delete_all
    ComptaLine.delete_all
    CheckDeposit.delete_all
    BankAccount.delete_all
    Cash.delete_all
  end

  # Renvoie une room qui correspond à une base de données
  def room_and_base(name)
    filename = name + '.sqlite3'
    r = Room.find_by_database_name(name)
    b = File.exist?(File.join(Rails.root, 'db', Rails.env, filename))
    # on a 4 cas
    # b n'existe pas mais r existe
    return r if r && b
    Apartment::Database.drop(name) if b  # on avait b mais pas r
    r.delete if r # on avait r mais pas b
    # et maintenant on recrée
    r = Room.new(database_name:name)
    r.user_id = 1
    r.save!
    r

  end

  # Malgré son nom, cette méthode ne crée que des écritures de type recettes
  #
  # Utiliser create_outcome_writing pour les écritures de type dépenses
  # 
  # permet de créer des écritures standard avec des valeurs par défaut 
  # pour le montant (99) et pour le mode de payment (Virement).
  #
  #
  def create_in_out_writing(montant=99, payment='Virement')
    if payment == 'Chèque'
      acc_id = @p.rem_check_account.id
    else
      acc_id = @baca.id
    end
    ecriture = @ib.in_out_writings.new({date:Date.today, narration:'créée par create_in_out_writing',
      :compta_lines_attributes=>{'0'=>{account_id:@income_account.id, nature:@n, credit:montant, payment_mode:payment},
        '1'=>{account_id:acc_id, debit:montant, payment_mode:payment}
      }
    })
    puts ecriture.errors.messages unless ecriture.valid?
    ecriture.save!
    ecriture
  end

  # Permet de créer une écriture de type dépenses avec par défaut un montant de 99 et un
  # mode de paiement de Virement
  #
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


  

end
