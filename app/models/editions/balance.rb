# coding: utf-8

require 'pdf_document/totalized'


module Editions


  # la classe Balance est spécifique en ce qu'elle utilise un titre de tableau 
  # assez complexe.
  # 
  # Cette ligne supplémentaire avec fusion de cases (par rapport au tableau global)
  # est donnée par la méthode before_title
  # 
  # La classe hérite de Totalized qui déscend elle-même de Simple qui descend de Base
  # 
  # Les variables d'instance rajoutées sont from_number, to_number, from_date et to_date.
  # #fill_default_values complète les données par défaut avec les columns_methods,
  # les alignements, les largeurs, les titres et les colonnes à totaliser. 
  #
  class Balance < PdfDocument::Totalized 
    

    attr_accessor :from_number, :to_number
    attr_reader :from_date, :to_date

    def initialize(period, source, options)
      @from_date = source.from_date
      @to_date = source.to_date
      @from_number = source.from_account
      @to_number = source.to_account
      @subtitle = "Du #{I18n::l from_date} au #{I18n.l to_date}"
      @select_method = 'accounts'
      super(period, source, options)
    end
    
    def fill_default_values
      self.columns_methods= %w(accounts.id number title period_id)
      self.columns_alignements=  [:left, :left, :right, :right, :right, :right, :right]
      self.columns_widths= [10, 40, 10, 10, 10, 10, 10]
      self.columns_titles= %w(Numéro Intitulé Débit Crédit Débit Crédit Solde)
      self.columns_to_totalize= [2,3,4,5,6]
      super
    end

     
    def before_title
      ['', "Soldes au #{I18n::l from_date}", 'Mouvements de la période',  "Soldes au #{I18n::l to_date}"]
    end
    
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      source.balance_lines.slice(offset, limit)
    end

    
    

      
    # appelle les méthodes adéquate pour chacun des éléments de la ligne
    # qui représente un account 
    def prepare_line(row)  
      [ row["number"],
        row["title"],
        row["cumul_debit_before"].to_f,
        row["cumul_credit_before"].to_f,
        row["movement_debit"].to_f,
        row["movement_credit"].to_f,
        row["movement_credit"].to_f - row["movement_debit"].to_f + 
          row["cumul_credit_before"].to_f - row["cumul_debit_before"].to_f ]
      
    end
    
    # Rails.logger.debug "Dans prepare_line de pdf_balance #{account.inspect}"
    #      [ account.number,
    #        account.title,
    #        ActionController::Base.helpers.number_with_precision(account.cumulated_debit_before(from_date),precision:2),
    #        ActionController::Base.helpers.number_with_precision(account.cumulated_credit_before(from_date),precision:2),
    #        ActionController::Base.helpers.number_with_precision(account.movement(from_date, to_date, :debit),precision:2),
    #        ActionController::Base.helpers.number_with_precision(account.movement(from_date, to_date, :credit),precision:2),
    #        ActionController::Base.helpers.number_with_precision(account.sold_at(to_date),precision:2)
    #      ]
    #    end
    
    # Crée le fichier pdf associé, le remplit et le rend
    def render
      pdf_file = Editions::PrawnBalance.new(:page_size => 'A4', :page_layout => :landscape) 
      pdf_file.fill_pdf(self)
      pdf_file.render 
    end




  end

end

