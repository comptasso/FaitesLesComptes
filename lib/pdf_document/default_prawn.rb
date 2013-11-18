# coding: utf-8

require 'prawn'

module PdfDocument
  
  class DefaultPrawn < PdfDocument::BasePrawn
    
    def fill_pdf(document) # la table des pages
      jclfill_stamp(document.stamp) # on initialise le tampon
      #
      # on démarre la table proprement dite
      # en calculant la largeur des colonnes
      col_widths = document.columns_widths.collect { |w| width*w/100 }
      
      1.upto(document.nb_pages) do |n|
        
        current_page = document.page(n)
        
        pad(05) { font_size(12) {entetes(current_page, cursor) } }
        
        stroke_horizontal_rule
        
        # une table de une ligne pour les titres
        table [current_page.table_title],
          :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :size=>10, :align=>:center }    do 
          col_widths.each_with_index {|w,i| column(i).width = w}
        end

        # une table de une ligne pour le report
        if current_page.table_report_line
          table [current_page.table_report_line],  :cell_style=>{:font_style=>:bold, :size=>10, :align=>:right } do 
            current_page.total_columns_widths.each_with_index {|w,i| column(i).width = width*w/100 }
          end
        end

        # la table des lignes proprement dites
        unless current_page.table_lines.empty?
          table current_page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5],:height => 16, :size=>10, :overflow=>:truncate} do
            col_widths.each_with_index {|w,i| column(i).width = w}
            document.columns_alignements.each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }
          end
        end


        # la table total et la table a reporter
        table [current_page.table_total_line, current_page.table_to_report_line],  :cell_style=>{:font_style=>:bold, :size=>10, :align=>:right } do
          document.total_columns_widths.each_with_index { |w,i| column(i).width = width*w/100 }
        end

        stamp 'fond'

        start_new_page unless (n == document.nb_pages)

      end
      
      numerote
    end
  end
  
end
