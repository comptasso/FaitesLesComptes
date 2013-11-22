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
      
      pad(05) { font_size(12) {entetes(current_page, cursor) } }

      stroke_horizontal_rule

      draw_before_title(document, current_page) # une ligne précédent les titres de colonnes
      draw_table_title(document, current_page) # la ligne des titres de colonne
      # une table de une ligne pour le report
      draw_report_line(current_page) if  current_page.table_report_line
      draw_lines(document, current_page) # les lignes de la table
      draw_total(current_page) # la ligne de total

    end
    
    def draw_before_title(document, page)
      page_width = width
      # une table de une ligne pour les titres
      table [document.before_title], :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }  do
        # 4 colonnes : 1ere vide et les 3 suivantes
        column(0).width = page_width*page.total_columns_widths[0]/100
        column(1).width = page_width*(page.total_columns_widths[1] +  page.total_columns_widths[2])/100
        column(2).width = page_width*(page.total_columns_widths[3] +  page.total_columns_widths[4])/100
        column(3).width = page_width*(page.total_columns_widths[5])/100
      end
    end
    
    def draw_table_title(document, page)
      table_columns_widths = set_table_columns_widths(document)
      table [page.table_title],
        :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }    do 
        table_columns_widths.each_with_index {|w,i| column(i).width = w}
      end
    end
    
    def draw_report_line(page)
      page_width = width
      table [page.table_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do
        page.total_columns_widths.each_with_index {|w,i| column(i).width = page_width*w/100 }
      end
    end
    
    def draw_lines(document, page)
      table_columns_widths = set_table_columns_widths(document)
      # la table des lignes proprement dites
      table page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate} do
        table_columns_widths.each_with_index {|w,i| column(i).width = w}
        document.columns_alignements.each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }

      end
    end
    
    def draw_total(page)
      page_width = width
      # la table total et la table a reporter
      table [page.table_total_line, page.table_to_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do
        page.total_columns_widths.each_with_index do |w,i|
          column(i).width = page_width*w/100
      
        end
      end
    end
    
    
  end
end