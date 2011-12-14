# -*- encoding : utf-8 -*-
module LinesHelper
  def debit_credit(montant)
    if montant > -0.01 && montant < 0.01
      '-'
    else
      number_with_precision(montant, :precision=> 2)
    end
  rescue
    ''
  end

 

  def submenu_helper(book)
    t=['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',' Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
#    content_tag(:div) do
#      concat(link_to('Janvier', book_lines_path(book, 'mois'=> 0)))
#       concat(link_to('Février', book_lines_path(book, 'mois'=> 1)))
#    end
#
#

content_tag :div do
   t.sum { |mois| content_tag(:p, mois) }
end
#    a= content_tag :span do
#      t.each_with_index do |mois,i|
#         link_to(mois, book_lines_path(book, "#{mois}"=> i))
#      end
#    end
#    a
  end
end
