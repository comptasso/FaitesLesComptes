# coding: utf-8

require 'pdf_document/default'


module PdfDocument


  class PdfBalance < PdfDocument::Default
    

    attr_accessor :from_number, :to_number



    # permet de choisir les colonnes que l'on veut sélectionner pour le document
    # set_columns appelle set_columns_widths pour calculer la largeur des colonnes
    # sur la base de largeurs égales.
    # Si on veut fixer les largeurs, il faut alors appeler set_columns_widths
    def set_columns(array_columns)
      @columns = array_columns
    end

    def set_columns_alignements(array_alignements)
      @columns_alignements = array_alignements
    end

    # calcule de nombre de pages; il y a toujours au moins une page
     # même s'il n'y a pas de lignes dans le comptes
     # ne serait-ce que pour afficher les soldes en début et en fin de période.

    # Je surcharge car on utilise ici balance_lines et non lines. 
     def nb_pages
       nb_lines = @source.balance_lines.count
       return 1 if nb_lines == 0
      (nb_lines/@nb_lines_per_page.to_f).ceil
     end




    def set_columns_widths(array_widths)
      @columns_widths = array_widths
    end

    def before_title
      ['', "Soldes au #{I18n::l from_date}", 'Mouvements de la période',  "Soldes au #{I18n::l to_date}"]
    end

    # renvoie les lignes de la page demandées
     def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      source.accounts.select(columns).order('number').where('number >= ? AND number <= ?', @from_number, @to_number).offset(offset).limit(limit)
     end

   
    # appelle les méthodes adéquate pour chacun des éléments de la ligne
    # qui représente un account 
    def prepare_line(account)
      Rails.logger.debug "Dans prepare_line de pdf_balance #{account.inspect}"
      [ account.number,
        account.title,
        '%0.2f' % account.cumulated_debit_before(from_date),
        '%0.2f' % account.cumulated_credit_before(from_date),
        '%0.2f' % account.movement(from_date, to_date, :debit),
        '%0.2f' % account.movement(from_date, to_date, :credit),
        '%0.2f' % account.cumulated_at(to_date,:debit),
        '%0.2f' % account.cumulated_at(to_date,:credit)
      ]
    end




  end

end

