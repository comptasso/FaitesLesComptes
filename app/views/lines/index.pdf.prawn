prawn_document(:page_size => 'A4', :page_layout => :landscape,
:background=>"#{Rails.root.to_s}/public/images/argent_liquide.jpg") do |pdf|
#         :info => {
#:Title => "Edition du livre #{@book.title}",:Author => "John Doe",:Subject => "Comptabilité",
# :Keywords => "#{@book.title} comptabilité, #{@organism.title}",:Creator => "#{@organism.title}",
# :Producer => "FaitesLesComptes with Prawn",
# :CreationDate => Time.now} } do |pdf|
#        :background=>'/assets/images/argent_liquide.jpg' }


width=pdf.bounds.right
time=l Time.now

# la table des pages
@listing.total_pages.times do |t|

    
    pdf.pad(05) do

        y_position = pdf.cursor
        pdf.bounding_box [0, y_position], :width => 100, :height => 40 do
            pdf.text @organism.title
            pdf.text @period.exercice
            pdf.text "Mois : #{l(@period.start_date.months_since(@mois.to_i),:format=> :month).capitalize}"
        end

        pdf.bounding_box [100, y_position], :width => width-200, :height => 40 do
            pdf.font_size(20) { pdf.text "#{@book.title}", :align=>:center }
        end

        pdf.bounding_box [width-100, y_position], :width => 100, :height => 40 do
            pdf.text "#{time}", :align=>:right
            pdf.text "Page #{t+1}/#{@listing.total_pages}",:align=>:right
        end

    end

    pdf.stroke_horizontal_rule
    # ajouter ici les soldes
    pdf.pad(5) do
pdf.indent(width- 374) do
        pdf.table [ ["Soldes antérieurs :", "#{two_decimals @listing.debit_before}", "#{two_decimals @listing.credit_before}"],
                    ["Mouvements du mois :", " #{two_decimals @listing.total_debit}", "#{two_decimals @listing.total_credit}"],
                    ["Totaux : ","#{two_decimals(@listing.debit_before+ @listing.total_debit)}", "#{two_decimals(@listing.credit_before + @listing.total_credit)}"] ],
                    :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold }   do
        column(0).width=220
        column(1..2).width=77
        column(1..2).style {|c| c.align=:right}
        end
     end
end
    
    # les lignes de la page
      pdf.table prawn_prepare_page(@listing.page(t+1)), :row_colors => ["FFFFFF", "DDDDDD"],  :header=> true , :cell_style=>{:padding=> [1,5,1,5] }   do
        column(0).width=77
        column(1).width = width - 220 - 3*77
        column(2).width = 110
        column(3).width = 110
        column(4).width=77
        column(5).width=77
         column(4..5).style {|c| c.align=:right}
        row(0).style {|c| c.font_style=:bold; c.align=:center }
         
     end

    pdf.start_new_page unless ((t+1) == @listing.total_pages)
end

end