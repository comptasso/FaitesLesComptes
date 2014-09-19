# coding: utf-8
require 'pdf_document/default.rb'


module Editions 
  # la classe GeneralLedger (journal général) permet d'imprimer le journal centralisateur
  # reprenant mois par mois les soldes des différentes journaux
  # le GeneralLedger se construit avec un period et s'appuie sur la classe MonthlyLedger
   class GeneralLedger < PdfDocument::Totalized

     include Compta::GeneralInfo
     attr_reader :period, :collection

      def initialize(period) 
        @period = period
        @columns_widths =  [20.0, 10.0, 40.0, 15.0, 15.0]  # cinq colonnes
        @total_columns_widths = [70.0, 15.0, 15.0]
        @columns_alignements = [:left, :left, :left, :right, :right]
        @columns_titles = %w(Mois Jnl Libellé Debit Credit)
        @columns_to_totalize=[3,4]
        @stamp = period.open ? 'Provisoire' : ''
        @title = 'Journal Général en refactor'
        @nb_lines_per_page = NB_PER_PAGE_LANDSCAPE
        @created_at = Time.now
        @orientation = :landscape

        set_collection
      end
      
      def precision
        2
      end

 
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      @collection.slice(offset, limit)
    end
    
    def set_collection
      lignes  = period.monthly_ledgers.collect {|ml| ml.lines_with_total }.flatten
      @collection = lignes.collect do |l|
         [l[:mois], l[:title], l[:description], l[:debit], l[:credit]]
      end
    end
    
    def prepare_line(line)
      line
    end

     
 

   end

end