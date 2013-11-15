require 'pdf_document/prawn_base'

module Editions
  # Editions::PrawnSheet hérite de Prawn::Base qui lui-même hérite de Prawn::Document
  # et apporte les méthodes telles que jc_fill_stamp
  #  
  # PrawnSheet n'a plus qu'à avoir deux méthodes spécialisées : fill_actif_pdf
  # et fill_passif_pdf pour fournir les deux types d'éditions à partir des mêmes données
  # (appelé ici document) 
  #
  class PrawnSheet < PdfDocument::PrawnBase
    
    
     
    # construit une page complète d'actif avec entêtes, tampon, titre de la table
    # toutes les lignes.
    # L'argument document est par exemple un Sheet ou un Extract
    def fill_actif_pdf(document)
      
      page = document.page(1)
      entetes(page, cursor)
      
      monpdf = self
      jclfill_stamp(document.stamp)
      column_widths = [40, 15, 15, 15, 15].collect { |w| width*w/100 }
      titles = [['', '', '', document.exercice, 'Précédent'], ['', 'Montant brut', "Amortisst\nProvision", 'Montant net', 'Montant net']]
      
      move_down 50
      # la table des lignes proprement dites
      table(titles + page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate}) do
        column_widths.each_with_index {|w,i| column(i).width = w}
        [:left, :right, :right, :right, :right].each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }
        # ici, on modifie le style des colonnes en fonction de la profondeur de l'objet
        # si c'est une rubrique de profondeur 0 ou 1 ou 2 (a priori des totaux ou sous-totaux, alors gras),
        # si c'est supérieur à 2 on reste en normal
        # si c'est -1, c'est que c'est un compte et donc en italique
    
        page.table_lines_depth.each_with_index do |d,i|
          row(i+2).font_style = monpdf.style(d) 

        end

      end
      
      stamp "fond"
    end
    
    # construit une page complète de passif avec entêtes, tampon, titre de la table
    # toutes les lignes
    def fill_passif_pdf(document)
      jclfill_stamp(document.stamp)
      page = document.page(1)
      entetes(page, cursor)
         
      column_widths = [70, 15, 15].collect { |w| width*w/100 }
      titles = [['', document.exercice, 'Précédent']]
     
      move_down 50
      monpdf = self
      # la table des lignes proprement dites
      table(titles + page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate}) do
        column_widths.each_with_index {|w,i| column(i).width = w}
        [:left, :right, :right].each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }
        # ici, on modifie le style des colonnes en fonction de la profondeur de l'objet
        # si c'est une rubrique de profondeur 0 ou 1 ou 2 (a priori des totaux ou sous-totaux, alors gras),
        # si c'est supérieur à 2 on reste en normal
        # si c'est -1, c'est que c'est un compte et donc en italique
    
        page.table_lines_depth.each_with_index do |d,i|
          row(i+1).font_style = monpdf.style(d) 

        end

      end
      
      stamp "fond"

    end
    
    
  
  end
  
end

