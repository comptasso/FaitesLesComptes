#coding: utf-8

module Pdflc
  
  
  # Cette classe permet d'enchaîner les listings de compte dans un grand livre.
  # Par rapport à FlcPage, elle est enrichie lors de l'initialisation de 
  # l'information sur le compte final (from_account, to_account). 
  # 
  # La table connait l'information sur le compte de départ, les options
  # from_account et to_account donnent les informations sur le compte de départ
  # et d'arrivée
  # 
  # 
  #
  # Par ailleurs, elle sait demander à FlcTable de se réinitialiser avec un 
  # nouveau compte
  class FlcBook 
    
    BOOK_TITLES = %w(N° Date Jnl Réf Libellé Nature Activité Débit Crédit)
    BOOK_WIDTHS = [6, 8, 6, 8, 24, 15, 15, 9, 9]
    BOOK_ALIGNMENTS = 7.times.collect {:left} + 2.times.collect {:right}
    BOOK_FIELDS =  ['w_id', 'w_date', 'b_abbreviation', 'w_ref', 'w_narration',
      'nat_name', 'dest_name', 'debit', 'credit']
    BOOK_SELECT =  ['writings.id AS w_id', 'writings.date AS w_date',
      'books.abbreviation AS b_abbreviation', 'writings.ref AS w_ref', 
      'writings.narration AS w_narration', 'natures.name AS nat_name',
      'destinations.name AS dest_name', 'debit',  'credit']
    
    attr_accessor :from_account, :to_account # pour pouvoir les mettre dans le
    # bon ordre
    attr_reader :period, :from_date, :to_date, :pdf
    attr_reader :table
   
    
    def initialize(options={})
      @from_account = options[:from_account]
      @fond = options[:fond]
      
      @period = from_account.period   
      @to_account = options[:to_account] || @from_account
      @from_date = options[:from_date] || period.start_date
      @to_date = options[:to_date] || period.close_date
      
      # on a besoin de la collection de comptes
      @accounts = set_accounts
      @organism_name = period.organism.title
      @exercice = period.long_exercice
      set_table(from_account)
      set_trame(from_account)
      @reports = set_reports(from_account)
    end
    
    def draw_pdf
   
      @pdf = Pdflc::FlcPage.new(BOOK_TITLES, BOOK_WIDTHS, BOOK_ALIGNMENTS,
        @reports, @table, @trame, fond:@fond)
      each_account do |acc|
        change_account(acc) 
        @pdf.draw_pdf(false) # pour ne pas paginer car on le fera à la fin
        @pdf.start_new_page unless acc == to_account
      end
          
      @pdf.numerote
      @pdf  

    end 
    
    
    
    
    protected
    
    # passe au compte suivant
    def each_account
      @accounts.each {|a| yield a if block_given?}
    end
    
    # change de compte, ce qui impose de changer le titre et le sous-titre de 
    # la trame;
    # De changer de compte pour la table
    def change_account(account)
      set_trame_title_and_subtitle(account)
      @table.change_arel(book_arel(account))
      @pdf.reports = set_reports(account)
    end
    
    def book_arel(account)
      account.compta_lines.with_writing_and_book.
        joins('LEFT OUTER JOIN destinations ON compta_lines.destination_id = destinations.id').
        joins('LEFT OUTER JOIN natures ON compta_lines.nature_id = natures.id').
        select(BOOK_SELECT).without_AN.
        range_date(from_date, to_date).
        order('writings.id')
    end
    
    def set_accounts
      self.from_account, self.to_account = to_account, from_account if
      to_account.number  < from_account.number
      period.accounts.order('number').
        where('number >= ? AND number <= ?', from_account.number, to_account.number)
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