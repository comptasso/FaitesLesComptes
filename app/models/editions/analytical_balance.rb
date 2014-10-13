require 'pdf_document/base_totalized'

module Editions

  class AnalyticalBalance < PdfDocument::BaseTotalized 
    
    
    EABTYPES = %w(String String Numeric Numeric)
    
    attr_reader :from_date, :to_date, :period_id, :created_at, :period
    
    # après attr_reader car le include vérifie que period est présent
    include Compta::GeneralInfo
    
    def initialize(cab) # cab pour Compta::AnalayticalBalance
      @period = cab.period 
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
    
    protected
    
    # collecte l'ensemble des lignes de la collection en commençant par les 
    # destinations et finit avec les lignes orphelines (sans destination) 
    def collection_for_pdf(cab)
      collection = []
      cab.destinations.each do |dest|
        collection << ab_lines_with_total(dest)
      end 
      collection << PdfDocument::TableLine.new(['', "Total sans activité", 
          cab.orphan_debit, cab.orphan_credit], EABTYPES, subtotal:true)
      collection << orphan_lines(cab)
      collection.flatten
    end
  
    
    # Collecte les lignes de détail des mouvements des comptes sans destination
    def orphan_lines(cab)
      cab.orphan_lines.map do |ol| 
        PdfDocument::TableLine.new([ol.number, ol.title, ol.t_debit, ol.t_credit],
          EABTYPES)
      end
    end
   
    # Fournit les lignes de détail pour une destination
    def ab_lines_with_total(dest)
      lwt = []
      dest.lines(period_id, from_date, to_date).each do |l|
      lwt <<  PdfDocument::TableLine.new([l.number, l.title, l.t_debit, l.t_credit],
          EABTYPES)
      end
      lwt.insert(0, title_line(dest)) 
      lwt.flatten
    end
   
    # donne la ligne de sous total pour une destination
    def title_line(destination)
      PdfDocument::TableLine.new(['',
    #      Compta::AnalyticalBalancesHelper::destination_and_sector_name(destination.name, destination.sector.name),
          "Total #{destination.name_with_sector}",
          destination.debit,
          destination.credit], EABTYPES, {subtotal:true})
    end
    
    
    
  
  
  
    
  end
  
end