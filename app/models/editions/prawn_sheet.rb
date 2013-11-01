# To change this template, choose Tools | Templates
# and open the template in the editor.

module Editions
  
  class PrawnSheet < Prawn::Document
    def style(depth)
      return :bold if (depth == 0 || depth == 1 || depth == 2)
      return :italic if depth == -1
    end
     
    def width
      bounds.right
    end
     
    # les entêtes de pages
    def entetes(page, y_position)
      bounding_box [0, y_position], :width => 150, :height => 40 do
        text page.top_left

      end

      bounding_box [150, y_position], :width => width-200, :height => 40 do
        font_size(20) { text page.title.capitalize, :align=>:center }
        #            text page.subtitle, :align=>:center
      end

      bounding_box [width-150, y_position], :width => 150, :height => 40 do
        text page.top_right, :align=>:right
      end

    end
     
    

    
  end
  
end

