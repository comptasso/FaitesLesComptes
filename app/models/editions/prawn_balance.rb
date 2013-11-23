require 'pdf_document/totalized_prawn'

module Editions
  
  
  # Une balance se distingue notamment par ses lignes de début de tables.
  # Il faut en effet afficher les têtes de colonnes mais il y a aussi à afficher 
  # la ligne 'Solde au ...' qui recouvre 2 colonnes;
  # 'Mouvement de la période' qui recouvre également 2 colonnes
  # 
  # Il y a donc une méthode supplémentaire qui est draw_before_title
  class PrawnBalance < PdfDocument::TotalizedPrawn
    
        
    # assure le remplissage du pdf avec le contenu du document
    def fill_pdf(document)
      @docu = document
      font_size(10) 
      jclfill_stamp(document.stamp) 
     
      # la table des pages
      document.pages.each_with_index do |current_page, index|
        contenu(current_page)
        stamp "fond"
        start_new_page unless (index + 1 == document.nb_pages)
      end
      
      numerote
    end
    
    protected
    
        
    # remplit le contenu d'une page
    def contenu(current_page)
      
      pad(05) { font_size(12) {entetes(current_page, cursor) } }

      stroke_horizontal_rule

      draw_before_title(current_page) # une ligne précédent les titres de colonnes
      draw_table_title(current_page) # la ligne des titres de colonne
      # une table de une ligne pour le report
      draw_report_line(current_page) if  current_page.table_report_line
      draw_table_lines(current_page) # les lignes de la table
      draw_total_lines(current_page) # la ligne de total

    end
    
    def draw_before_title(page)
      
      # une table de une ligne pour les titres
      table [docu.before_title], :cell_style=>TITLE_STYLE  do |table|
        # 4 colonnes : 1ere vide et les 3 suivantes
        table.column(0).width = width*page.total_columns_widths[0]/100
        table.column(1).width = width*(page.total_columns_widths[1] +  page.total_columns_widths[2])/100
        table.column(2).width = width*(page.total_columns_widths[3] +  page.total_columns_widths[4])/100
        table.column(3).width = width*(page.total_columns_widths[5])/100
      end
    end
    
    
    
    
    
    
    
  end
end