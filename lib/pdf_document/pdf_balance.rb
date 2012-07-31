# coding: utf-8

require 'pdf_document/base'

module PdfDocument
  class PdfBalance < PdfDocument::Base
    # permet de choisir les colonnes que l'on veut sélectionner pour le document
    # set_columns appelle set_columns_widths pour calculer la largeur des colonnes
    # sur la base de largeurs égales.
    # Si on veut fixer les largeurs, il faut alors appeler set_columns_widths
    #
    def set_columns(array_columns)
      @columns = array_columns
    end

    def set_columns_alignements(array_alignements)
      @columns_alignements = array_alignements
    end

    def set_columns_widths(array_widths)
      @columns_widths = array_widths
    end
      
    
    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    def prepare_line(line)
      [ line.number,
        line.title,
        line.cumulated_before(Date.today, :debit),
        line.cumulated_before(Date.today, :credit),
        line.movement(Date.today.beginning_of_year, Date.today.end_of_year, :debit),
        line.movement(Date.today.beginning_of_year, Date.today.end_of_year, :credit),
        line.cumulated_at(Date.today.end_of_year,:debit),
        line.cumulated_at(Date.today.end_of_year,:credit)
      ]
    end


  end

end

