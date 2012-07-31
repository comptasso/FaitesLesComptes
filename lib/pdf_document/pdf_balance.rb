# coding: utf-8

require 'pdf_document/base'

module PdfDocument
  class PdfBalance < PdfDocument::Base
    # permet de choisir les colonnes que l'on veut sélectionner pour le document
    # set_columns appelle set_columns_widths pour calculer la largeur des colonnes
    # sur la base de largeurs égales.
    # Si on veut fixer les largeurs, il faut alors appeler set_columns_widths
    #

    attr_accessor :from_number, :to_number

    def set_columns(array_columns)
      @columns = array_columns
    end

    def set_columns_alignements(array_alignements)
      @columns_alignements = array_alignements
    end



    def set_columns_widths(array_widths)
      @columns_widths = array_widths
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
      [ account.number,
        account.title.truncate(40),
        account.cumulated_before(from_date, :debit),
        account.cumulated_before(from_date, :credit),
        account.movement(from_date, to_date, :debit),
        account.movement(from_date, to_date, :credit),
        account.cumulated_at(to_date,:debit),
        account.cumulated_at(to_date,:credit)
      ]
    end




  end

end

