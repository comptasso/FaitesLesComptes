require 'pdf_document/base_totalized'

module Editions

  class AnalyticalBalance < PdfDocument::BaseTotalized
    
    EABTYPES = %w(String String Numeric Numeric)
    
    attr_reader :from_date, :to_date, :period_id, :created_at
    
    
    def initialize(cab) # cab pour Compta::AnalayticalBalance
      @period_id = cab.period_id
      @from_date = cab.from_date
      @to_date = cab.to_date
      @subtitle = "Du #{I18n::l from_date} au #{I18n.l to_date}"
      
      @collection = collection_for_pdf(cab) 
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
      [ line[:number], line[:title], 
        ActionController::Base.helpers.number_with_precision(line[:debit],precision:2),
        ActionController::Base.helpers.number_with_precision(line[:credit],precision:2)]
          
    end
    
    protected
    
    def collection_for_pdf(cab)
      
      collection = []
      cab.destinations.each do |dest|
        collection << ab_lines_with_total(dest)
      end 
      collection << PdfDocument::TableLine.new(['', "Sans activité", 
          cab.orphan_debit, cab.orphan_credit], EABTYPES, subtotal:true)
      collection << orphan_lines(cab)
      collection.flatten
    end
  
    def orphan_lines(cab)
      cab.orphan_lines.map do |ol| 
        PdfDocument::TableLine.new([ol.number, ol.title, ol.t_debit, ol.t_credit],
          EABTYPES)
      end
    end
   
    # pour l'édition des pdf avec des sous totaux par destination
    # on utilise une table à 4 colonnes 
    def ab_lines_with_total(dest)
      lwt = []
      dest.lines(period_id, from_date, to_date).each do |l|
      lwt <<  PdfDocument::TableLine.new([l.number, l.title, l.t_debit, l.t_credit],
          EABTYPES)
      end
      lwt.insert(0, title_line(dest)) 
      lwt.flatten
    end
   
    def title_line(destination)
      PdfDocument::TableLine.new(['',
          "#{destination.name} (#{destination.sector.name})",
          destination.debit,
          destination.credit], EABTYPES, {subtotal:true})
    end
  
  
  
    
  end
  
end