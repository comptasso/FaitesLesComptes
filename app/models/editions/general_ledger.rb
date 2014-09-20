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
      @collection = lignes
    end
    
   
    
    protected
    
    # récupère les lignes à partir des monthly_ledgers
    # ajoute éventuellement des lignes blanches pour éviter les ruptures de page
    def lignes
      period.monthly_ledgers.collect { |ml| monthly_lines(ml) }.flatten
    end
      
    
    def monthly_lines(ml)
      mls = ml.lines_with_total
      res = []
      res << table_line(mls.first, {subtotal:true})
      if (mls.size > 2)
        mls.slice(1, (mls.size) -2).each {|l| res << table_line(l) }
      end
      res << table_line(mls.last, {subtotal:true})
      res
    end
    
    GL_STRUCTURE = %w(String, String, String, Numeric, Numeric)
    
    # construit une TableLine à partir d'une ligne
    def table_line(line, options = {})
      PdfDocument::TableLine.new([line[:mois], line[:title], 
          line[:description], line[:debit], line[:credit]],
        GL_STRUCTURE, options
      )
    end
    
#    def blank_line
#      PdfDocument::TableLine.new(['', '', '', '', ''],
#        GL_STRUCTURE)
#    end
    
    # GL_BLANK_LINE = {mois:'', title:'', description:'', debit:'', credit:''} 

     
 

  end

end