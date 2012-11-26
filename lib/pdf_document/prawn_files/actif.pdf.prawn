# fichier Sheet.
# Ce fichier prawn ne fait qu'afficher le layout,
# les tables sont insérées Prawn pour des éditions simples sans total ni report
# ni tampon
width = bounds.right

y_position = cursor
page = doc.page(1)


        bounding_box [0, y_position], :width => 100, :height => 40 do
            text page.top_left

        end

        bounding_box [100, y_position], :width => width-200, :height => 40 do
            font_size(20) { text page.title.capitalize, :align=>:center }
#            text page.subtitle, :align=>:center
        end

        bounding_box [width-100, y_position], :width => 100, :height => 40 do
            text page.top_right, :align=>:right
        end



move_down 50

# on démarre la table proprement dite
# en calculant la largeur des colonnes
column_widths = doc.columns_widths.collect { |w| width*w/100 }


 table [['', doc.exercice, 'Précédent']],
    :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center } do
    column(0).width = column_widths[0]
    column(1).width = column_widths[1] + column_widths[2] + column_widths[3]
    column(2).width = column_widths[4]
 end


 table [page.table_title],
  :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }    do
         column_widths.each_with_index {|w,i| column(i).width = w}
      end


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
