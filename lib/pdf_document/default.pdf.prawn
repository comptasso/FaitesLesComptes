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



width = bounds.right

# création du tampon de fond
if stamp_dictionary_registry['fond'].nil?
create_stamp('fond') do
  rotate(40) do
    fill_color "bbbbbbb"
    font_size(120) do
      text_rendering_mode(:stroke) do
        draw_text("Provisoire", :at=>[250, -150])
      end
    end
    fill_color "000000"
  end
end
end

# la table des pages
1.upto(doc.nb_pages) do |n|
    page = doc.page(n)
    pad(05) do

        y_position = cursor
        bounding_box [0, y_position], :width => 150, :height => 40 do
            text page.top_left

        end

        bounding_box [150, y_position], :width => width-300, :height => 40 do
            font_size(20) { text page.title, :align=>:center }
            text page.subtitle, :align=>:center
        end

        bounding_box [width-150, y_position], :width => 150, :height => 40 do
            text page.top_right, :align=>:right
        end

    end

    stroke_horizontal_rule

# on démarre la table proprement dite
# en calculant la largeur des colonnes
column_widths = doc.columns_widths.collect { |w| width*w/100 }

# une table de une ligne pour les titres
table [page.table_title],
  :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }    do 
         column_widths.each_with_index {|w,i| column(i).width = w}
      end

# une table de une ligne pour le report
if page.table_report_line
table [page.table_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do 
         page.total_columns_widths.each_with_index {|w,i| column(i).width = width*w/100 }
      end
end

# la table des lignes proprement dites
unless page.table_lines.empty?
  table page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5],:height => 16, :overflow=>:truncate} do
      column_widths.each_with_index {|w,i| column(i).width = w}
      doc.columns_alignements.each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }
  end
end


# la table total et la table a reporter
table [page.table_total_line, page.table_to_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do
  page.total_columns_widths.each_with_index do |w,i|
      column(i).width = width*w/100
      
  end
end


  stamp 'fond'

   start_new_page unless (n == doc.nb_pages)

end