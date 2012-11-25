# fichier Sheet.
# Ce fichier prawn ne fait qu'afficher le layout,
# les tables sont insérées Prawn pour des éditions simples sans total ni report
# ni tampon
width = bounds.right

y_position = cursor
page = doc.page(1)


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

