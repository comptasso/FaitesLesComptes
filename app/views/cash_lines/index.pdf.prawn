prawn_document(:filename=>"#{@organism.title}-#{@cash.name}-#{l Time.now}.pdf", :page_size => 'A4', :page_layout => :landscape) do |pdf|

    width=pdf.bounds.right
    time=l Time.now

    # le tampon "brouillard"
    pdf.create_stamp("brouillard") do
        pdf.rotate(45) do
            pdf.fill_color "bbbbbbb"

            pdf.font_size(120) do
                pdf.text_rendering_mode(:stroke) do
                    pdf.draw_text("Brouillard", :at=>[250, -150])
                end
            end
            pdf.fill_color "000000"
        end
    end


# la table des pages
    @monthly_extract.total_pages.times do |t|

        pdf.pad(05) do # rappel pad crée un petit espace
            y_position = pdf.cursor
            # la boîte de gauche
            pdf.bounding_box [0, y_position], :width => 200, :height => 40 do
                pdf.font_size(12) do
                    pdf.text @organism.title
                    pdf.text @period.exercice
                    pdf.text "Mois : #{@monthly_extract.month}"
                end
            end
            # la boite du centre
            pdf.bounding_box [100, y_position], :width => width-200, :height => 40 do
                pdf.font_size(20) { pdf.text "Caisse : #{@cash.name}", :align=>:center }
            end
            # le pavé de droite
            pdf.bounding_box [width-100, y_position], :width => 100, :height => 40 do
                pdf.font_size(12) do
                    pdf.text "#{time}", :align=>:right
                    pdf.text "Page #{t+1}/#{@monthly_extract.total_pages}",:align=>:right
                end
            end

        end

        pdf.stroke_horizontal_rule
        # les soldes
        pdf.pad(5) do
            pdf.font_size(10)
            pdf.indent(width- 270) do
                pdf.table [ ["Soldes antérieurs :", "#{two_decimals @monthly_extract.debit_before}", "#{two_decimals @monthly_extract.credit_before}"],
                            ["Mouvements du mois :", " #{two_decimals @monthly_extract.total_debit}", "#{two_decimals @monthly_extract.total_credit}"],
                            ["Totaux : ","#{two_decimals(@monthly_extract.debit_before+ @monthly_extract.total_debit)}", "#{two_decimals(@monthly_extract.credit_before + @monthly_extract.total_credit)}"] ],
                            :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold }   do
                column(0).width=130
                column(1..2).width=70
                column(1..2).style {|c| c.align=:right}
            end
         end
    end

    prawn_page =  @monthly_extract.page(t+1)
    prawn_page.insert(0, @monthly_extract.titles)

       
    pdf.table prawn_page,
     :row_colors => ["FFFFFF", "DDDDDD"],
     :header=> true ,
     :cell_style=>{:padding=> [1,5,1,5] }   do
        column(0).width = 60
        column(1).width = 60
        column(2).width = width - 260 - 2*70 - 60 - 60
        column(3).width = 130
        column(4).width = 130
        column(5).width=70
        column(6).width=70
        column(5..6).style {|c| c.align=:right}
        row(0).style {|c| c.font_style=:bold; c.align=:center }
    end

          pdf.stamp "brouillard" if @monthly_extract.brouillard?
          pdf.start_new_page unless ((t+1) == @monthly_extract.total_pages)
       end

end