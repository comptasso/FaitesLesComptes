prawn_document(:filename=>"#{@organism.title}-Statistiques-#{l Time.now}.pdf", :page_size => 'A4', :page_layout => :landscape) do |pdf|

    width = pdf.bounds.right
    time = l Time.now

   

# la table des pages
    @listing.each_page do |page|

        pdf.pad(05) do # rappel pad crée un petit espace
            y_position = pdf.cursor
            # la boîte de gauche
            pdf.bounding_box [0, y_position], :width => 200, :height => 40 do
                pdf.font_size(12) do
                    pdf.text @organism.title
                    pdf.text @period.exercice
                    
                end
            end
            # la boite du centre
            pdf.bounding_box [100, y_position], :width => width-200, :height => 40 do
                pdf.font_size(20) { pdf.text "Statistiques par natures", :align=>:center }
                pdf.font_size(12) { pdf.text "Filtre : #{@filter_name}", :align=>:center } if @filter_name
            end
            # le pavé de droite
            pdf.bounding_box [width-100, y_position], :width => 100, :height => 40 do
                pdf.font_size(12) do
                    pdf.text "#{time}", :align=>:right
                    pdf.text "Page #{page.number}/#{@listing.nb_pages}",:align=>:right
                end
            end

        end

    
    prawn_page =  page.formatted_lines 
    prawn_page.insert(0, page.title)
    prawn_page.insert(1, page.report_line) if page.report_line
    prawn_page.insert(-1, page.total_page_line)
    prawn_page.insert(-1, page.to_report_line)

        # les lignes de la page
    pdf.font_size(8)
    nbc = page.nb_cols - 1
    pdf.table prawn_page, :row_colors => ["FFFFFF", "DDDDDD"],  :header=> true , :cell_style=>{:padding=> [1,5,1,5] }   do
        column(0).width = width - nbc*50
        column(1..nbc).width = 50
        column(1..nbc).style {|c| c.align=:right}
        row(0).style {|c| c.font_style=:bold; c.align=:center }
        row(1).style {|c| c.font_style=:bold} if page.report_line
        row(-2..-1).style {|c| c.font_style=:bold }
    end
          
          pdf.start_new_page unless page.is_last?
       end

end