# fichier Sheet pour les documents de type passif,
# c'est à dire ayant seulement deux colonnes de montant.
# 



width = bounds.right

# la méthode du tampon
if stamp_dictionary_registry['fond'].nil?
create_stamp("fond") do
  rotate(65) do
    fill_color "bbbbbbb"

    font_size(120) do
      text_rendering_mode(:stroke) do
        draw_text(doc.stamp, :at=>[250, -150])
      end
    end
    fill_color "000000"
  end
end
end




y_position = cursor
page = doc.page(1)


        bounding_box [0, y_position], :width => 150, :height => 40 do
            text page.top_left

        end

        bounding_box [150, y_position], :width => width-300, :height => 40 do
            font_size(20) { text page.title.capitalize, :align=>:center }
#            text page.subtitle, :align=>:center
        end

        bounding_box [width-150, y_position], :width => 150, :height => 40 do
            text page.top_right, :align=>:right
        end



move_down 50

# on démarre la table proprement dite
# en calculant la largeur des colonnes
column_widths = [70, 15, 15].collect { |w| width*w/100 }


 table [page.table_title],
    :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center } do
    column_widths.each_with_index {|w,i| column(i).width = w}
 end


# la table des lignes proprement dites
 table page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate} do
    column_widths.each_with_index {|w,i| column(i).width = w}
    [:left, :right, :right].each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }
    # ici, on modifie le style des colonnes en fonction de la profondeur de l'objet
    # si c'est une rubrique de profondeur 0 alors normal,
    # si c'est supérieur à 0 alors en gras
     page.table_lines_depth.each_with_index do |d,i|
        row(i).font_style = :bold if (d == 0 || d == 1)
     end

 end

stamp "fond"
