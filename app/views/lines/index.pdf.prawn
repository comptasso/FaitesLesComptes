



# la table des pages
@listing.total_pages.times do |t|

    pdf.stroke_horizontal_rule
    # pdf.text "#{pdf.cursor}"
    pdf.pad(05) do

        y_position = pdf.cursor
        pdf.bounding_box [0, y_position], :width => 100, :height => 40 do
            pdf.transparent(0.5) { pdf.stroke_bounds }
            pdf.text @organism.title
            pdf.text @period.exercice
            pdf.text "Mois : #{l(@period.start_date.months_since(@mois.to_i),:format=> :month).capitalize}"
        end

        pdf.bounding_box [100, y_position], :width => 200, :height => 40 do
            pdf.transparent(0.5) { pdf.stroke_bounds }
            pdf.text "#{@book.title}"
            
        end

        pdf.bounding_box [300, y_position], :width => 100, :height => 40 do
            pdf.transparent(0.5) { pdf.stroke_bounds }
            pdf.text "#{l Time.now}"
            pdf.text "Page #{t}/#{@listing.total_pages}"

        end

    end

    pdf.stroke_horizontal_rule
    # ajouter ici les soldes
    pdf.pad(5) do
        pdf.text "Soldes antérieurs : #{@listing.debit_before} - #{@listing.credit_before}"
        pdf.text "Mouvements du mois : #{@listing.total_debit} - #{@listing.total_credit}"
        pdf.text "Totaux : #{@listing.debit_before+ @listing.total_debit} - #{@listing.credit_before + @listing.total_credit}"
    end

    pdf.stroke_horizontal_rule
    # les lignes de la page
      pdf.table @listing.page(t)

    pdf.start_new_page unless t=@listing.total_pages
end

