# coding: utf-8
require 'pdf_document/default.rb'


module Editions 
  # la classe GeneralLedger (journal général) permet d'imprimer le journal centralisateur
  # reprenant mois par mois les soldes des différentes journaux
  # le GeneralLedger se construit avec un period et s'appuie sur la classe MonthlyLedger
  class GeneralLedger < PdfDocument::Totalized

    include Compta::GeneralInfo
    attr_reader :collection

    def initialize(period)
      fill_default_values
      @period = period
      @columns_widths =  [20.0, 10.0, 40.0, 15.0, 15.0]  # cinq colonnes
      @total_columns_widths = [70.0, 15.0, 15.0]
      @columns_alignements = [:left, :left, :left, :right, :right]
      @columns_titles = %w(Mois Journal Libellé Debit Credit)
      @columns_to_totalize=[3,4]
      @stamp = period.open ? 'Provisoire' : ''
      @title = 'Journal Général'
      @subtitle = "Du #{I18n::l period.start_date} au #{I18n::l period.close_date}"
      @created_at = Time.now
      
      set_collection
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
    
    def fill_default_values
      @orientation ||= :landscape
      @subtitle ||= ''
      @nb_lines_per_page ||= NB_PER_PAGE_LANDSCAPE
      @precision ||= 2
    end
    
    # récupère les lignes à partir des monthly_ledgers
    # ajoute éventuellement des lignes blanches pour éviter les ruptures de 
    # page pendant un groupe de lignes relevant du même MonthlyLedger
    def lignes
      compteur  = 0
      period.monthly_ledgers.collect do |ml|
        
        mls = monthly_lines(ml)
        rows_left = (22 -(compteur % 22))
        if rows_left < mls.size && mls.size <= 22
          rows_left.times { mls.insert(0, blank_line)}
        end
        compteur += mls.size
        mls
      end.flatten
    end
    
    # A partir d'un MonthlyLedger construit une table de TableLine avec 
    # la première et la dernière marquée comme étant des subtotal pour 
    # apparaître en gras et ne pas être recomptée dans les totaux des colonnes
    # débit et crédit.
    def monthly_lines(ml)
      mls = ml.lines_with_total
      res = []
      res << head_line(mls.first, {subtotal:true})
      if (mls.size > 2)
        mls.slice(1, (mls.size) -2).each {|l| res << table_line(l) }
      end
      res << head_line(mls.last, {subtotal:true})
      res
    end
    
    GL_STRUCTURE = %w(String, String, String, Numeric, Numeric)
    
    # construit une ligne de titre ou de total
    def head_line(line, options = {})
      PdfDocument::TableLine.new([line[:mois], '', 
          '', line[:debit], line[:credit]],
        GL_STRUCTURE, options
      )
    end
    
    # construit une TableLine à partir d'une ligne
    def table_line(line, options = {})
      PdfDocument::TableLine.new(['', line[:abbreviation], line[:title], 
          line[:debit], line[:credit]],
        GL_STRUCTURE, options
      )
    end
    
    # fournit une ligne blanche
    def blank_line
      PdfDocument::TableLine.new(['', '', '', '', ''],
        GL_STRUCTURE)
    end
    
  end

end