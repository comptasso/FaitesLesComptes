#coding: utf-8

module Pdflc
  
    BOOK_TITLES = %w(N° Date Jnl Réf Libellé Nature Activité Débit Crédit)
    BOOK_WIDTHS = [6, 8, 6, 8, 24, 15, 15, 9, 9]
    BOOK_ALIGNMENTS = 7.times.collect {:left} + 2.times.collect {:right}
    BOOK_FIELDS =  ['w_id', 'w_date', 'b_abbreviation', 'w_ref', 'w_narration',
      'nat_name', 'dest_name', 'debit', 'credit']
    BOOK_SELECT =  ['writings.id AS w_id', 'writings.date AS w_date',
      'books.abbreviation AS b_abbreviation', 'writings.ref AS w_ref', 
      'writings.narration AS w_narration', 'natures.name AS nat_name',
      'destinations.name AS dest_name', 'debit',  'credit']
  
  
  # Cette classe permet de produire les fichiers pdf pour un listing de compte
  # La table connait l'information sur le compte 
  # 
  
  class FlcListing
    
    
    
    attr_accessor :from_account
    attr_reader :period, :from_date, :to_date, :pdf
    attr_reader :table
   
    
    def initialize(options={})
      @from_account = options[:from_account]
      @fond = options[:fond]
      
      @period = from_account.period   
      @from_date = options[:from_date] || period.start_date
      @to_date = options[:to_date] || period.close_date
      
      # on a besoin de la collection de comptes
      
      @organism_name = period.organism.title
      @exercice = period.long_exercice
      set_table(from_account)
      set_trame(from_account)
      @reports = set_reports(from_account)
    end
    
    def draw_pdf
   
      @pdf = Pdflc::FlcPage.new(BOOK_TITLES, BOOK_WIDTHS, BOOK_ALIGNMENTS,
        @reports, @table, @trame, fond:@fond)
      @pdf.draw_pdf(false) 
        
      @pdf.numerote 
      @pdf  

    end 
     
    protected
    
    
    
    # construit l'arel nécessaire à collecter en une seule requête l'ensemble
    # des informations nécessaires.
    def book_arel(account)
      account.compta_lines.with_writing_and_book.
        joins('LEFT OUTER JOIN destinations ON compta_lines.destination_id = destinations.id').
        joins('LEFT OUTER JOIN natures ON compta_lines.nature_id = natures.id').
        select(BOOK_SELECT).without_AN.
        range_date(from_date, to_date).
        order('writings.id')
    end
    
    
    def set_reports(account)
      [account.cumulated_debit_before(from_date),
        account.cumulated_credit_before(from_date)]
    end
        
    def set_trame(account)
      @trame = Pdflc::FlcTrame.new(
        organism_name:@organism_name, 
        exercice:@exercice
      )
      set_trame_title_and_subtitle(account)
    end
    
    def set_table(account)
      @table = Pdflc::FlcTable.new(
        book_arel(account), 22, BOOK_FIELDS, [7,8], [1] 
      )
    end
    
    def set_trame_title_and_subtitle(account)
      @trame.title = "Listing compte #{account.number}"
      @trame.subtitle =  "#{account.title.truncate 50} - Du #{I18n::l from_date} au #{I18n.l to_date}"
    end
    
    
  end
  
  
end