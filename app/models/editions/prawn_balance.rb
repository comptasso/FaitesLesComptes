require 'pdf_document/totalized_prawn'

module Editions
  
  class PrawnBalance < PdfDocument::TotalizedPrawn
    
        
    # assure le remplissage du pdf avec le contenu du document
    def fill_pdf(document)
      font_size(10) 
      jclfill_stamp(document.stamp)
     
      # la table des pages
      document.pages.each_with_index do |current_page, index|
        contenu(document, current_page)
        stamp "fond"
        start_new_page unless (index + 1 == document.nb_pages)
      end
      
      numerote
    end
    
    protected
    
    # calcule la largeur des colonnes de la table principale
    def set_table_columns_widths(document)
      document.columns_widths.collect { |w| width*w/100 }
    end
    
        
    # remplit le contenu d'une page
    def contenu(document, current_page)
      # recopie de variables locales car les questions de portée posent autrement
      # un problème dans le dessin des tables
        table_columns_widths = set_table_columns_widths(document)
        page_width = width
        
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

        draw_table_title(document, current_page)

        # une table de une ligne pour le report
        if current_page.table_report_line
          table [current_page.table_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do
            current_page.total_columns_widths.each_with_index {|w,i| column(i).width = page_width*w/100 }
          end
        end

        # la table des lignes proprement dites
        table current_page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate} do
          table_columns_widths.each_with_index {|w,i| column(i).width = w}
          document.columns_alignements.each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }

        end

        # la table total et la table a reporter
        table [current_page.table_total_line, current_page.table_to_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do
          current_page.total_columns_widths.each_with_index do |w,i|
            column(i).width = page_width*w/100
      
          end
        end

    end
    
    def draw_table_title(document, page)
      table_columns_widths = set_table_columns_widths(document)
      table [page.table_title],
          :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }    do 
          table_columns_widths.each_with_index {|w,i| column(i).width = w}
        end
    end
    
    
    
    
  end
end