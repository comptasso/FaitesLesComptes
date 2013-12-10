require 'pdf_document/base_prawn'

module Editions
  # Editions::PrawnSheet hérite de Prawn::Base qui lui-même hérite de Prawn::Document
  # et apporte les méthodes telles que jc_fill_stamp
  #  
  # PrawnSheet n'a plus qu'à avoir deux méthodes spécialisées : fill_actif_pdf
  # et fill_passif_pdf pour fournir les deux types d'éditions à partir des mêmes données
  # (appelé ici document) 
  #
  class PrawnSheet < PdfDocument::BasePrawn
    
    
     
    # construit une page complète d'actif avec entêtes, tampon, titre de la table
    # toutes les lignes.
    # L'argument document est par exemple un Sheet ou un Extract
    def fill_pdf(document, numeros = false)
      @docu = document
      jclfill_stamp(document.stamp)
        
      page = document.page(1)
      entetes(page, cursor)
       
      move_down 50
      
      draw_table_title(page)
      draw_table_lines(page)
      
      
      stamp "fond"
      
      numerote if numeros
      # on ne met pas ici numérote car on peut enchainer les documents
    end
    
    protected
    
    # surcharge pour tenir compte de la prise en compte de la profondeur de 
    # chaque ligne, dont dépend le style
    def draw_table_lines(page)
      # la table des lignes proprement dites
      table page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"], 
        :header=> false , 
        :column_widths=>col_widths,
        :cell_style=>LINE_STYLE  do |table|
        docu.columns_alignements.each_with_index {|alignement,i|  table.column(i).style {|c| c.align = alignement}  }
        page.table_lines_depth.each_with_index do |d,i|
          table.row(i).font_style = style(d) 
          table.row(i).size = pdf_font_size(d)
        end
      end
      
    end
    
    # définit le style d'une ligne en fonction de la profondeur de la rubrique
    # pour rappel, depth = -1 pour une ligne de détail de compte
    # sinon depth = 0 pour la rubrique racine puis +1 à chaque fois qu'on 
    # descend dans l'arbre des rubriques.
    def style(depth)
      case depth
      when -1 then :italic
      when 0..2 then :bold
      end
    end
    
    def pdf_font_size(depth)
      case depth
      when -1 then 8
      when 0..2 then 12
      else 10
      end
    end
  
  end
end