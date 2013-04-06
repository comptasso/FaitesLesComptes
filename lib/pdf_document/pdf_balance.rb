# coding: utf-8

require 'pdf_document/totalized'


module PdfDocument


  # la classe Balance est spécifique en ce qu'elle utilise un titre de tableau 
  # assez complexe.
  # 
  # Ce titre est donné par la méthode before_title
  #
  class PdfBalance < PdfDocument::Totalized
    

    attr_accessor :from_number, :to_number
    attr_reader :from_date, :to_date

    def initialize(period, source, options)
      super(period, source, options)
      @from_date = source.from_date
      @to_date = source.to_date
      @from_number = source.from_account
      @to_number = source.to_account
      @subtitle = "Du #{I18n::l from_date} au #{I18n.l to_date}"
      @select_method = 'accounts'
      set_columns %w(accounts.id number title period_id)
      set_columns_alignements  [:left, :left, :right, :right, :right, :right, :right]
      set_columns_widths [10, 40, 10, 10, 10, 10, 10]
      set_columns_titles %w(Numéro Intitulé Débit Crédit Débit Crédit Solde)
      set_columns_to_totalize [2,3,4,5,6]
    end

     
    def before_title
      ['', "Soldes au #{I18n::l from_date}", 'Mouvements de la période',  "Soldes au #{I18n::l to_date}"]
    end

      
    # appelle les méthodes adéquate pour chacun des éléments de la ligne
    # qui représente un account 
    def prepare_line(account)
      Rails.logger.debug "Dans prepare_line de pdf_balance #{account.inspect}"
      [ account.number,
        account.title,
        ActionController::Base.helpers.number_with_precision(account.cumulated_debit_before(from_date),precision:2),
        ActionController::Base.helpers.number_with_precision(account.cumulated_credit_before(from_date),precision:2),
        ActionController::Base.helpers.number_with_precision(account.movement(from_date, to_date, :debit),precision:2),
        ActionController::Base.helpers.number_with_precision(account.movement(from_date, to_date, :credit),precision:2),
        ActionController::Base.helpers.number_with_precision(account.sold_at(to_date),precision:2)
      ]
    end




  end

end

