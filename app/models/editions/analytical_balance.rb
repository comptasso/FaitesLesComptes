require 'pdf_document/base_totalized'

module Editions

  class AnalyticalBalance < PdfDocument::BaseTotalized
    
    attr_reader :from_date, :to_date, :created_at
    
    
    def initialize(cab) # cab pour Compta::AnalayticalBalance
      @from_date = cab.from_date
      @to_date = cab.to_date
      @subtitle = "Du #{I18n::l from_date} au #{I18n.l to_date}"
      
      @collection = cab.collection_for_pdf 
      @columns_to_totalize= [2,3]
      @columns_methods = %w(number title debit credit) # le seul intérêt ici est 
      # de dire qu'il y a quatre colonnes car on a surchargé prepare_line
      @title = 'Balance analytique'
      @columns_widths = [15, 55, 15, 15]
      @columns_alignements = [:left, :left, :right, :right]
      @source = cab
      @created_at = Time.now
      default_total_columns_widths
      fill_default_values
      @columns_titles = %w(Numero Libellé Débit Crédit)
    end
    
    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    # A surcharger lorsqu'on veut faire un traitement de la ligne
    # Par défaut applique number_with_precision à toutes les valeurs numériques
    def prepare_line(line)
      [ line[:number],
        line[:title], 
        line[:debit].blank? ? line[:debit] : ActionController::Base.helpers.number_with_precision(line[:debit], :precision=>2) ,
        line[:credit].blank? ? line[:credit] : ActionController::Base.helpers.number_with_precision(line[:credit], :precision=>2) 
      ]
    end
    
  end
  
end