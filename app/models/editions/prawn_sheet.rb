# To change this template, choose Tools | Templates
# and open the template in the editor.


  class Editions::PrawnSheet < Prawn::Document
     def style(depth)
       return :bold if (depth == 0 || depth == 1 || depth == 2)
     end
  end

