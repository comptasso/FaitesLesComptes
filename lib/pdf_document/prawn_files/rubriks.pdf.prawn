# fichier Prawn pour des éditions simples sans total ni report
# ni tampon
width = bounds.right

page = doc.page
move_down 50

# on démarre la table proprement dite
# en calculant la largeur des colonnes
column_widths = doc.columns_widths.collect { |w| width*w/100 }


# la table des lignes proprement dites
 table page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate} do
    column_widths.each_with_index {|w,i| column(i).width = w}
    doc.columns_alignements.each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }
    # ici, on modifie le style des colonnes en fonction de la profondeur de l'objet
    # si c'est une rubrique de profondeur 0 alors normal,
    # si c'est supérieur à 0 alors en gras
    page.table_lines_depth.each_with_index do |d,i|
        row(i).font_style = :bold if d > 0
    end

 end
