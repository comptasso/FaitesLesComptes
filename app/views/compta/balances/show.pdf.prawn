prawn_document(:page_size => 'A4', :page_layout => :landscape) do |pdf|

width=pdf.bounds.right
time=l Time.now


# la méthode du tampon brouillard
pdf.create_stamp("fond") do
pdf.rotate(40) do
pdf.fill_color "bbbbbbb"

pdf.font_size(120) do
 pdf.text_rendering_mode(:stroke) do
  pdf.draw_text("Provisoire", :at=>[250, -150])
 end
end
pdf.fill_color "000000"
end
end





# la table des pages
1.upto(@balance.nb_pages) do |t|
    
    pdf.pad(05) do

        y_position = pdf.cursor
        pdf.bounding_box [0, y_position], :width => 100, :height => 40 do
            pdf.text @organism.title
            pdf.text @period.exercice
            
        end

        pdf.bounding_box [100, y_position], :width => width-200, :height => 40 do
            pdf.font_size(20) { pdf.text "Balance des comptes", :align=>:center }
            pdf.text "Du #{l @balance.from_date} Au #{l @balance.to_date}", :align=>:center
        end

        pdf.bounding_box [width-100, y_position], :width => 100, :height => 40 do
            pdf.text "#{time}", :align=>:right
            pdf.text "Page #{t}/#{@balance.nb_pages}",:align=>:right
        end

    end

    pdf.stroke_horizontal_rule

 pdf.table [ [" ", "Soldes au #{l @balance.from_date}","Mouvements \n de la période","Soldes au #{l @balance.to_date}" ] ],
  :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold, :align=>:center }    do

        column(0).width=width- 6*77
        column(1..3).width=77*2
        
        end
   

    
    # les lignes de la page
      pdf.table balance_prepare_page(@balance.page(t)), :row_colors => ["FFFFFF", "DDDDDD"],  :header=> false , :cell_style=>{:padding=> [1,5,1,5] }   do
        column(0).width=110      # le numéro de compte
        column(1).width = width - 110 - 6*77 # le libéllé
        column(2).width = 77 # solde cumul avant débit
        column(3).width = 77 # cumul avant crédit
        column(4).width=77 # movement debit
        column(5).width=77 # movement credit
column(6).width=77 # solde cumulé après débit
column(7).width=77 # solde cumulé après crédit
         column(2..7).style {|c| c.align=:right}
        row(0).style {|c| c.font_style=:bold; c.align=:center }
         
     end

# on affiche les sous totaux
if @balance.nb_pages > 1 # mais seulement si plus d'un page
  pdf.table [ ["Totaux page"] + prepare_total_balance(@balance.sum_page(t)) ],   :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold }   do

        column(0).width=width- 6*77
        column(1..6).width=77
        column(1..6).style {|c| c.align=:right}
        end
 end

 # On affiche les soldes à chaque page
    pdf.pad(5) do


        pdf.table [ ["Totaux"] + prepare_total_balance(@balance.total_balance) ],   :cell_style=>{:padding=> [1,5,1,5], :font_style=>:bold }   do

        column(0).width=width- 6*77
        column(1..6).width=77
        column(1..6).style {|c| c.align=:right}
        end
     end

pdf.stamp "fond" if @balance.provisoire?

    pdf.start_new_page unless (t == @balance.nb_pages)
end

end