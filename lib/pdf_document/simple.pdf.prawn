# fichier Prawn pour des éditions simples sans total ni report
# ni tampon
width = bounds.right


# la table des pages
1.upto(doc.nb_pages) do |n|
    page = doc.page(n)
    pad(05) do

        y_position = cursor
        bounding_box [0, y_position], :width => 100, :height => 40 do
            text page.top_left

        end

        bounding_box [100, y_position], :width => width-200, :height => 40 do
            font_size(20) { text page.title, :align=>:center }
#            text page.subtitle, :align=>:center
        end

        bounding_box [width-100, y_position], :width => 100, :height => 40 do
            text page.top_right, :align=>:right
            
        end

    end

    stroke_horizontal_rule

# on démarre la table proprement dite
# en calculant la largeur des colonnes
column_widths = doc.columns_widths.collect { |w| width*w/100 }


 table [page.table_title],
  :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }    do
         column_widths.each_with_index {|w,i| column(i).width = w}
      end


# la table des lignes proprement dites
 table page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate} do
    column_widths.each_with_index {|w,i| column(i).width = w}
    doc.columns_alignements.each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }

 end



 

   pdf.start_new_page unless (n == doc.nb_pages)

end