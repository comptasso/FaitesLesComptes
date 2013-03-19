# ce fichier est destiné à être utilisé dans les différentes éditions pour
# générer les entêtes des pages.
#
# Voir pour l'inserer le code dans balance.pdf.prawn

font_size(12) do
y_position = cursor
bounding_box [0, y_position], :width => 150, :height => 40 do
    text_box current_page.top_left
end

bounding_box [150, y_position], :width => width-300, :height => 40 do
    font_size(20) { text current_page.title, :align=>:center }
    text current_page.subtitle, :align=>:center
end

bounding_box [width-150, y_position], :width => 150, :height => 40 do
    text_box current_page.top_right, :align=>:right
end

end