# coding: utf-8

require 'prawn'
require 'pdf_document/simple_prawn'

module PdfDocument
  
  


  # ce modèle par défaut permet d'imprimer un document de plusieurs pages avec des
  # pavés de présentation, ligne de titre, sous-titre, report des valeurs,...
  #
  # Il faut pour cela que le document réponde à certaines méthodes
  # nb_pages : nombre de pages total du document
  # page(n) : retourne la page
  # page.top_left : renvoie le texte du pavé gauche
  # page.title and page.subtitle pour les titres et sous titres du milieu
  # page.top_right : renvoie le texte de droite
  # columns_widths : renvoie la largeur des colonnes en % de la largeur de page
  # page.table_title pour la première ligne de la table
  # page.table_report_line : lignes pour le report
  # page.table_lines : la table des lignes proprement dite
  # page.table_total_line
  # page.table_to_report_line
  class TotalizedPrawn < PdfDocument::SimplePrawn
    
    REPORT_LINE_STYLE = {:font_style=>:bold, :align=>:right }
          
    def fill_pdf(document, numeros = true)
      @docu = document
      jclfill_stamp(document.stamp) # on initialise le tampon
      
      document.pages.each_with_index do |current_page, index|
        contenu(current_page)
        stamp 'fond'
        start_new_page unless document.nb_pages == index+1
      end
      numerote if numeros
    end
    
    
    
    protected
    
    
      # remplit le contenu d'une page
    def contenu(current_page)
      pad(05) { font_size(12) {entetes(current_page, cursor) } }
      stroke_horizontal_rule
      draw_table_title(current_page) # la ligne des titres de colonne
      # une table de une ligne pour le report
      font_size(8) do
        draw_report_line(current_page) if  current_page.table_report_line
        draw_table_lines(current_page) # les lignes de la table
        draw_total_lines(current_page) # la ligne de total
      end

    end
    
    
    def total_col_widths
      docu.total_columns_widths.collect { |w| width*w/100 }
    end
    
    def draw_report_line(page)
      table [page.table_report_line], column_widths:total_col_widths,  :cell_style=>REPORT_LINE_STYLE 
    end
    
    def draw_total_lines(page)
      table [page.table_total_line, page.table_to_report_line], 
        column_widths:total_col_widths,  :cell_style=>REPORT_LINE_STYLE 
    end
      
  end
  
end