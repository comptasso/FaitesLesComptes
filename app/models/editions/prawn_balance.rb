require 'pdf_document/prawn_base'

module Editions
  
  class PrawnBalance < PdfDocument::PrawnBase
    
    
    
    def fill_pdf(document)
      font_size(10) 
      
      
      page_width = width
      jclfill_stamp(document.stamp)
      
      # calcul des largeurs de colonnes
      column_widths = document.columns_widths.collect { |w| width*w/100 }
  
      # la table des pages
      1.upto(document.nb_pages) do |n|
    
        current_page = document.page(n)
        pad(05) { font_size(12) {entetes(current_page, cursor) } }

        stroke_horizontal_rule

        # une table de une ligne pour les titres
        table [document.before_title], :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }  do
          # 4 colonnes : 1ere vide et les 3 suivantes
          column(0).width = page_width*current_page.total_columns_widths[0]/100
          column(1).width = page_width*(current_page.total_columns_widths[1] +  current_page.total_columns_widths[2])/100
          column(2).width = page_width*(current_page.total_columns_widths[3] +  current_page.total_columns_widths[4])/100
          column(3).width = page_width*(current_page.total_columns_widths[5])/100
        end

        table [current_page.table_title],
          :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }    do 
          column_widths.each_with_index {|w,i| column(i).width = w}
        end

        # une table de une ligne pour le report
        if current_page.table_report_line
          table [current_page.table_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do
            current_page.total_columns_widths.each_with_index {|w,i| column(i).width = page_width*w/100 }
          end
        end

        # la table des lignes proprement dites
        table current_page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate} do
          column_widths.each_with_index {|w,i| column(i).width = w}
          document.columns_alignements.each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }

        end

        # la table total et la table a reporter
        table [current_page.table_total_line, current_page.table_to_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do
          current_page.total_columns_widths.each_with_index do |w,i|
            column(i).width = page_width*w/100
      
          end
        end


        stamp "fond"

      start_new_page unless (n == document.nb_pages)

      end
      
      numerote
    end
  end
end