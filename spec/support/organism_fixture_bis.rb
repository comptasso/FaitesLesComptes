# coding: utf-8

# Module regroupant des méthodes pour générer les éléments minimaux d'organisation
# A utiliser en mettant include OrganismFixture dans la fichier spec ou on utilisera la méthode
module OrganismFixtureBis
  
  def find_or_create_schema_test
    Apartment::Database.create(SCHEMA_TEST) unless Apartment::Database.db_exist?(SCHEMA_TEST)
    # puts Apartment::Database.list_schemas
  end

  def clean_main_base
    drop_non_public_schemas_except_schema_test
    find_or_create_schema_test
    Apartment::Database.switch()
    User.delete_all
    Holder.delete_all
    Room.delete_all
  end
  
  def erase_writings
    Writing.delete_all
    ComptaLine.delete_all
  end
  
  # TODO refactorisé pour obtenir plus facilement une base saine de tests
  def use_test_organism(status='Association')
    Apartment::Database.switch(SCHEMA_TEST)
    @o = Organism.first
    unless @o && @o.status == status
      create_organism(status) # rappel : fait déja un appel à get_organism_instances
      return
    end
    @p = @o.periods.first
    unless @p # c'est qu'on a effacé les exercices dans des tests
      create_organism 
      return
    end
    erase_writings
    get_organism_instances
    @o
  end

  #
  def drop_non_public_schemas_except_schema_test
    Apartment::Database.list_schemas.reject {|name| name == 'public'}.each do |schema|
      Apartment::Database.drop(schema) unless schema == SCHEMA_TEST
    end
  end

  def create_only_user
    # TODO enlever le clean_main_base en nettoyant au fil des 
    # tests
    clean_main_base
    @cu =  User.new(name:'quidam', :email=>'bonjour@example.com', password:'bonjour1' )
    @cu.confirmed_at = Time.now
    @cu.save!
  end


  def create_user
    create_only_user
    @h = @cu.holders.new(status:'owner')
    @r = Room.where('database_name =  ?', SCHEMA_TEST).first
    @r  ||= Room.new(database_name:SCHEMA_TEST, title:'Asso test',
      status:'Association') 
    puts @r.errors.messages unless @r.valid?
    @r.save!
    @h.room_id = @r.id
    @h.save!
    @cu
  end
  
  def use_test_user
    @cu = User.first || create_user
    @r = @cu.rooms.first
  end

  def clean_organism
    
    Apartment::Database.process(SCHEMA_TEST) do
      Organism.delete_all
      Period.delete_all
      Book.delete_all
      Nature.delete_all
      Account.delete_all
      ComptaLine.delete_all
      BankAccount.delete_all
      Cash.delete_all
      Destination.delete_all
      Folio.delete_all
      Nomenclature.delete_all
      Rubrik.delete_all
      Sector.delete_all
    end if Apartment::Database.db_exist?(SCHEMA_TEST)
    
  end


  def create_minimal_organism
    create_organism
  end
 
  # créé un organisme dans la base SCHEMA_TEST
  # l'argument status permet de choisir le type d'organisme
  # Par défaut, une association
  def create_organism(status='Association')
    clean_organism
    Apartment::Database.switch(SCHEMA_TEST)
    @o = Organism.create!(title: 'ASSO TEST', database_name:SCHEMA_TEST,
      comment: 'Un commentaire', status:status)
    @p = @o.periods.create!(start_date: Date.today.beginning_of_year, 
      close_date: Date.today.end_of_year)
    @p.create_datas
    get_organism_instances 
  end
  
  
  
  def get_organism_instances
    # TODO utiliser des ||= pour réduire le nombre de requetes
    @sector = @o.sectors.first
    @ba = @o.bank_accounts.first
    # puts @ba.inspect
    @ib = @o.income_books.first # les livres sont créés par un after_create
    @ob = @o.outcome_books.first
    @od = @o.od_books.first
    @c=  @o.cashes.first || @o.cashes.create!(:name=>'Magasin', sector_id:@sector.id)
  
    @baca = @ba.current_account(@p) # pour baca pour BankAccount Current Account
    # puts @baca.inspect
    @caca = @c.current_account(@p) # pour caca pour CashAccount Current Account
    # puts @caca.inspect
    @n = @p.natures.depenses.first 
    @d = @o.destinations.first rescue @o.destinations.create!(name:'Non affecte')
  end
  
  def find_second_bank
    b2 = @o.bank_accounts.where('number = ?', '123Z').first
    b2 ||= create_second_bank
  end
  
  def create_second_bank
    b2 = @o.bank_accounts.new(:bank_name=>'Deuxième banque', :number=>'123Z',
      nickname:'Compte épargne')
    b2.sector_id = @sector.id
    puts b2.errors.messages unless b2.valid?  
    b2.save!
    b2
  end
  
  def create_second_nature
    nat2 = @p.natures.new(:name=>'deuxieme nature')
    nat2.book_id = @o.outcome_books.first.id
    nat2.save!
    nat2
  end
  
  def find_second_nature
    nat2 = @p.natures.where('name = ?', 'deuxieme nature').first
    nat2 || create_second_nature    
  end
  
  def create_second_period
    p = @o.periods.create!(:start_date=>(@p.close_date + 1), close_date:(@p.close_date.years_since(1)))
    p.create_datas
    p
  end
  
  def find_second_period
    @p.next_period? ? @p.next_period : create_second_period
  end
  
  def create_bank_extract
    @ba.bank_extracts.create!(:begin_date=>Date.today.beginning_of_month, 
      end_date:Date.today.end_of_month,
      begin_sold:1,
      total_debit:2,
      total_credit:5)
  end
  
  def find_bank_extract
    be = @ba.bank_extracts.first
    be ||= create_bank_extract
  end

  # utile pour les requests qui nécessitent d'être identifié
  # il faut appeler avant create_user (pour pouvoir utiliser login_as('quidam')
  def login_as(name)
    visit '/'
    fill_in 'user_email', :with=>'bonjour@example.com'
    fill_in 'user_password', :with=>'bonjour1'
    click_button 'Valider'
  end
  
  def create_first_member(organism, params = {})
    name = params[:name] || 'Defaut'
    number = params[:number] || 'Adh001'
    forname = params[:forname] || 'Jean'
    birthdate = params[:birthdate].to_date rescue Date.civil(1955,6,6)
    am = Adherent::Member.new(name:name, number:number, forname:forname, birthdate:birthdate)
    am.organism_id = organism.id
    am.save!
  end

  
  # Permet de créer une écriture de type dépenses avec par défaut un montant de 99 et un
  # mode de paiement de Virement
  #
  def create_outcome_writing(montant=99, payment='Virement', dest_id=nil)
    # TODO passer à un outcome_account
    @income_account = @p.accounts.classe_7.first
    ecriture = @ob.in_out_writings.new(
      {date:Date.today,
       narration:'ligne créée par la méthode create_outcome_writing',
       :compta_lines_attributes=>{
         '0'=>{account_id:@income_account.id, 
           destination_id:dest_id,
           nature:@n, debit:montant, payment_mode:payment},
         '1'=>{account_id:@baca.id, credit:montant, payment_mode:payment}
        }
      })
    puts ecriture.errors.messages unless ecriture.valid?
    ecriture.save
    ecriture
  end
  
  # Options est un hash 
  def create_writing(book, options)
    
    # gestion des valeurs par défaut et des options
    d = options[:date] || Date.today
    narration = options[:narration] || 'ligne créée par la méthode create_writing'
    aid = options[:account_id] || @p.accounts.classe_7.first
    if options[:nature_id]
      nature = Nature.find_by_id(options[:nature_id])
    else
      nature = @p.natures.depenses.first 
    end
    montant = options[:montant] || 33.33
    p_mode = options[:p_mode] || 'Virement'
    if options[:finance_account_id] 
      baca_id = options[:finance_account_id]
    else
      ba = @o.bank_accounts.first
      baca_id = ba.current_account(@p).id
    end
      
    # création de l'écriture
      ecriture = book.in_out_writings.new(
      {date:d,
       narration:narration,
       :compta_lines_attributes=>{
         '0'=>{account_id:aid, 
           destination_id:options[:dest_id],
           nature:nature, debit:montant, payment_mode:p_mode},
         '1'=>{account_id:baca_id, credit:montant, payment_mode:p_mode}
        }
      })
    
    # vérification de la validité et enregistrement
    puts ecriture.errors.messages unless ecriture.valid?
    ecriture.save
    ecriture
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
    # TODO refactoriser en utilisant des options et des valeurs par défaut
    # pour plus de souplesse.
    @income_account = @p.accounts.classe_7.first
    if payment == 'Chèque'
      acc_id = @p.rem_check_account.id
    else
      acc_id = @baca.id
    end
    ecriture = @ib.in_out_writings.new({date:Date.today, narration:'créée par create_in_out_writing',
        :compta_lines_attributes=>{
          '0'=>{account_id:@income_account.id,
            nature:@n, credit:montant, payment_mode:payment},
          '1'=>{account_id:acc_id, debit:montant, payment_mode:payment}
        }
      })
    puts ecriture.errors.messages unless ecriture.valid?
    ecriture.save!
    ecriture
  end
  
  def create_cash_income(montant = 59)
    @income_account = @o.accounts.classe_7.first
     
    ecriture = @ob.in_out_writings.new({date:Date.today, narration:'ligne créée par la méthode create_cash_income',
        :compta_lines_attributes=>{'0'=>{account_id:@income_account.id, nature:@n, credit:montant, payment_mode:'Espèces'},
          '1'=>{account_id:@caca.id, debit:montant, payment_mode:'Espèces'}
        }
      })
    #puts ecriture.errors.messages unless ecriture.valid?
    ecriture.save!
    ecriture
  end
  
  # créé un transfert , 
  # par défaut de 99.99 de la banque vers la caisse à la date du jour
  def create_transfer(options = {})
    date = options[:date] || Date.today
    amount = options[:amount] || 99.99.to_s
    from_account_id = options[:from_account] || BankAccount.first.current_account(@p).id
    to_account_id = options[:to_account] || Cash.first.current_account(@p).id
    narration = options[:narration] || 'virement interne créé par méthode de test'
        
    ecriture = @od.transfers.new({date:date, narration:narration,
        :compta_lines_attributes=>{
          '0'=>{account_id:from_account_id, credit:amount},
          '1'=>{account_id:to_account_id, debit:amount}
        }
      })
    puts ecriture.errors.messages unless ecriture.valid?
    ecriture.save
    ecriture
  end
  
  # Crée une série de comptes dont les comptes sont donnés par le premier 
  # argument (un tableau) et l'exercice par le deuxième (facultatif)
  def create_accounts(numbers, period_id=1)
    numbers.collect do |n|
      # s'il existe on ne le recrée pas
      a = Account.find_by_number(n)
      unless a
        a = Account.new(number:n, title:"Numero#{n}")
        a.period_id = period_id
        puts a.inspect unless a.valid?
        puts a.errors.messages unless a.valid?
        a.save!
      end
      a
    end
  end
  

end
