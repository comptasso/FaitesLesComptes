# To change this template, choose Tools | Templates
# and open the template in the editor.

module Editions
  
  class PrawnPassifSheet < Editions::PrawnSheet
    
     
    def fill_pdf(document)
      y_position = cursor
      page = document.page(1)
      entetes(page, y_position)
     column_widths = [70, 15, 15].collect { |w| width*w/100 }
      monpdf = self

      titles = [['', document.exercice, 'Précédent']]
      move_down 50
      # la table des lignes proprement dites
      table(titles + page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate}) do
        column_widths.each_with_index {|w,i| column(i).width = w}
        [:left, :right, :right].each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }
        # ici, on modifie le style des colonnes en fonction de la profondeur de l'objet
        # si c'est une rubrique de profondeur 0 ou 1 ou 2 (a priori des totaux ou sous-totaux, alors gras),
        # si c'est supérieur à 2 on reste en normal
        # si c'est -1, c'est que c'est un compte et donc en italique
    
        page.table_lines_depth.each_with_index do |d,i|
          row(i+2).font_style = monpdf.style(d) 

        end

      end

    end
  end
  
end

