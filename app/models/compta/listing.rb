# coding: utf-8


module Compta



  # la classe Listing sert à éditer un compte. Elle n'est pas persistente mais
  # s'appuie sur ActiveRecord::Base pour avoir les associations.
  #
  # Ceci suppose d'avoir une définition des colonnes virtuelles
  # d'où les premières lignes de cette classe
  class Listing < ActiveRecord::Base 

    include Utilities::Sold
    include Utilities::ToCsv
    include Utilities::PickDateExtension # apporte la méthode de classe pick_date_for

    def self.columns() @columns ||= []; end

    def self.column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
    end

    column :from_date, :date
    column :to_date, :date
    column :account_id, :integer
     
    belongs_to :account
   
    pick_date_for :from_date, :to_date # donne les méthodes begin_date_picker et end_date_picker
    # utilisées par le input as:date_picker

    attr_accessible :from_date_picker, :to_date_picker, :from_date, :to_date, :account_id
   

    # je mets within_period en premier car je préfère les affichages Dates invalide ou hors limite
    # que obligatoire (sachant que le form n'affiche que la première erreur).
    validates :from_date, :to_date, within_period:true
    validates :from_date, :to_date, :account_id, :presence=>true

    # donne le cumul du débit ou du crédit (sens) à une date donnée
    delegate :cumulated_at, :to=>:account


    def with_default_values
      self.from_date ||= period.start_date
      self.to_date ||= period.close_date
      self
    end

    def solde_debit_avant
      cumulated_debit_before(from_date)
    end

    def solde_credit_avant
      cumulated_credit_before(from_date)
    end

    def total_debit
      movement(from_date, to_date, 'debit')
    end

    def total_credit
      movement(from_date, to_date, 'credit')
    end


    def lines
      @lines ||= account.compta_lines.listing(from_date, to_date)
    end

    # permet notamment de contrôler les limites de date
    def period
      account.period rescue nil 
    end

    # utile pour le formulaire de saisie pour changer de compte
    def accounts
      period.accounts
    end

    def to_csv(options = {col_sep:"\t"})
      CSV.generate(options) do |csv|
        csv << ["Liste des écritures du compte #{account.number}",'', '',  '', '', '','', '']
        csv << %w(Date Journal Référence Libellé Nature Activité Débit Crédit)
        csv << ["Soldes au #{I18n::l from_date}",'', '', '', '','', reformat(solde_debit_avant), reformat(solde_credit_avant) ]
        lines.each do |l|
          csv << [I18n::l(l.date), l.book.title, l.ref, l.narration, l.nature_name, l.destination_name, reformat(l.debit), reformat(l.credit)]
        end
        csv << ['Totaux', '', '', '', '','', reformat(total_debit), reformat(total_credit)]
        csv << ["Soldes au #{I18n::l to_date}", '', '', '', '','', reformat(solde_debit_avant + total_debit), reformat(solde_credit_avant + total_credit)]
      end
    end
   
    
    # création d'un pdf à partir des options déjà connues. 
    # S'appuie sur le module Pdflc
    def to_pdf
      stamp  = "brouillard" unless account.all_lines_locked?(from_date, to_date)
      options = {fond:stamp} if stamp
      Pdflc::FlcPage.new(%w(N° Date Jnl Réf Libellé Nature Activité Débit Crédit), # les titres
      [6, 8, 6, 8, 24, 15, 15, 9, 9], # les largeurs
      7.times.collect {:left} + 2.times.collect {:right}, # les alignements
      [solde_debit_avant, solde_credit_avant], # les reports
      set_table, set_trame, options)
    end

    

    # remplace les points décimaux par des virgules pour s'adapter au paramétrage
    # des tableurs français
    def reformat(number)
      sprintf('%0.02f',number).gsub('.', ',') if number
    end
    
    def set_trame
      Pdflc::FlcTrame.new(
        title:"Listing compte #{account.number}",
        subtitle: "#{account.title} - Du #{I18n::l from_date} au #{I18n.l to_date}",
        organism_name:period.organism.title, 
        exercice:period.long_exercice
    )
    end
    
    # utilise l'arel, avec 22 lignes par page, la liste des champs demandés, 
    # puis les champs à totaliser et le champ date
    def set_table
      Pdflc::FlcTable.new(listing_arel, 22, listing_fields, [7,8], [1] ) 
    end
    
    protected
    
    def listing_arel
      account.compta_lines.with_writing_and_book.
        joins('LEFT OUTER JOIN destinations ON compta_lines.destination_id = destinations.id').
        joins('LEFT OUTER JOIN natures ON compta_lines.nature_id = natures.id').
        select(listing_select).without_AN.
        range_date(from_date, to_date).
        order('writings.id')
    end
    
    def listing_fields
      ['w_id', 'w_date', 'b_abbreviation', 'w_ref', 'w_narration',
      'nat_name', 'dest_name', 'debit', 'credit']
    end
    
    def listing_select
      ['writings.id AS w_id', 'writings.date AS w_date',
        'books.abbreviation AS b_abbreviation', 'writings.ref AS w_ref', 
        'writings.narration AS w_narration', 'natures.name AS nat_name',
        'destinations.name AS dest_name', 'debit',  'credit']
    end




  end
end