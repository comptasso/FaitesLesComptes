 
width = bounds.right
font_size(10) 

# la méthode du tampon brouillard
create_stamp("fond") do
  rotate(40) do
    fill_color "bbbbbbb"

    font_size(120) do
      text_rendering_mode(:stroke) do
        draw_text(doc.stamp, :at=>[250, -150])
      end
    end
    fill_color "000000"
  end
end


# la table des pages
1.upto(doc.nb_pages) do |n|
    current_page = doc.page(n)
    pad(05) do

# TODO voir pour faire une méthode de ces deux lignes
# afin de pouvoir utiliser des partials
    jc_render = Proc.new {|temple, jcpdf| jc_text = File.open(temple, 'r') {|f| f.read  }; jcpdf.instance_eval(jc_text, temple) }
    jc_render.call("lib/pdf_document/prawn_files/entetes.pdf.prawn", self)

   end

    stroke_horizontal_rule

# on démarre la table proprement dite
# en calculant la largeur des colonnes
column_widths = doc.columns_widths.collect { |w| width*w/100 }



# une table de une ligne pour les titres
table [doc.before_title], :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }  do
  # 4 colonnes : 1ere vide et les 3 suivantes
    column(0).width = width*current_page.total_columns_widths[0]/100
    column(1).width = width*(current_page.total_columns_widths[1] +  current_page.total_columns_widths[2])/100
    column(2).width = width*(current_page.total_columns_widths[3] +  current_page.total_columns_widths[4])/100
    column(3).width = width*(current_page.total_columns_widths[5])/100
end
table [current_page.table_title],
  :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }    do 
         column_widths.each_with_index {|w,i| column(i).width = w}
      end



# une table de une ligne pour le report
if current_page.table_report_line
table [current_page.table_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do
         current_page.total_columns_widths.each_with_index {|w,i| column(i).width = width*w/100 }
      end
end

# la table des lignes proprement dites
table current_page.table_lines ,  :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5], :height => 16, :overflow=>:truncate} do
    column_widths.each_with_index {|w,i| column(i).width = w}
    doc.columns_alignements.each_with_index {|alignement,i|  column(i).style {|c| c.align = alignement}  }

end

# la table total et la table a reporter
table [current_page.table_total_line, current_page.table_to_report_line],  :cell_style=>{:font_style=>:bold, :align=>:right } do
  current_page.total_columns_widths.each_with_index do |w,i|
      column(i).width = width*w/100
      
  end
end


  stamp "fond"

   pdf.start_new_page unless (n == doc.nb_pages)

end