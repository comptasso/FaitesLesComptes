# coding: utf-8

# Module regroupant des méthodes pour générer les éléments minimaux d'organisation
# A utiliser en mettant include OrganismFixture dans la fichier spec ou on utilisera la méthode
module OrganismFixtureBis

  def clean_main_base
    drop_non_public_schemas_except_assotest1
    Apartment::Database.switch()
    User.delete_all
    Room.delete_all
  end

  #
  def drop_non_public_schemas_except_assotest1
    Apartment::Database.list_schemas.reject {|name| name == 'public'}.each do |schema|
      Apartment::Database.drop(schema) unless schema == 'assotest1'
    end
  end

  def create_only_user
    clean_main_base
    @cu =  User.new(name:'quidam', :email=>'bonjour@example.com', password:'bonjour1' )
    @cu.confirmed_at = Time.now
    @cu.save!
  end


  def create_user
    create_only_user
    @r = @cu.rooms.create!(database_name:'assotest1')
    
  end

  def clean_assotest1
    Apartment::Database.process('assotest1') do
      Organism.all.each {|o| o.destroy }
      Nature.delete_all
      Account.delete_all
      ComptaLine.delete_all
      BankAccount.delete_all
      Cash.delete_all
    end
  end


  def create_minimal_organism
    create_organism
  end

  def create_organism
    clean_assotest1
    Apartment::Database.switch('assotest1')
    @o = Organism.create!(title: 'ASSO TEST', database_name:'assotest_1', status:'Association')
    @p = @o.periods.create!(start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year)
    # @n = @p.natures.create!(name: 'Essai', :income_outcome=>false)
    get_organism_instances
  end

  def get_organism_instances
    @ba= @o.bank_accounts.first
    @ib = @o.income_books.first # les livres sont créés par un after_create
    @ob = @o.outcome_books.first
    @od = @o.od_books.first
    @c=@o.cashes.first
    @c.update_attribute(:name, 'Magasin'); @c.save;
    @baca = @ba.current_account(@p) # pour baca pour BankAccount Current Account
    @caca = @c.current_account(@p) # pour caca pour CashAccount Current Account
    @n = @p.natures.depenses.first
  end

  # utile pour les requests qui nécessitent d'être identifié
  # il faut appeler avant create_user (pour pouvoir utiliser login_as('quidam')
  def login_as(name)
    visit '/'
    fill_in 'user_email', :with=>'bonjour@example.com'
    fill_in 'user_password', :with=>'bonjour1'
    click_button 'Valider'
  end

  
  # Permet de créer une écriture de type dépenses avec par défaut un montant de 99 et un
  # mode de paiement de Virement
  #
  def create_outcome_writing(montant=99, payment='Virement')
    @income_account = @o.accounts.classe_7.first
    
    ecriture = @ob.in_out_writings.create!({date:Date.today, narration:'ligne créée par la méthode create_outcome_writing',
        :compta_lines_attributes=>{'0'=>{account_id:@income_account.id, nature:@n, debit:montant, payment_mode:payment},
          '1'=>{account_id:@baca.id, credit:montant, payment_mode:payment}
        }
      })
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
    @income_account = @o.accounts.classe_7.first
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
  
  def create_cash_income(montant = 59)
    @income_account = @o.accounts.classe_7.first
    ecriture = @ob.in_out_writings.create!({date:Date.today, narration:'ligne créée par la méthode create_cash_income',
      :compta_lines_attributes=>{'0'=>{account_id:@income_account.id, nature:@n, credit:montant, payment_mode:'Espèces'},
        '1'=>{account_id:@caca.id, debit:montant, payment_mode:'Espèces'}
      }
    })
     ecriture
  end
  

end
