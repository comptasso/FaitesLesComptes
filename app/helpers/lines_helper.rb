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

 
  def submenu_helper(book, period)
   t=[]
   if period
     t= period.list_months
   else
    t=['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',' Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
   end

   content_tag :span do
     s=''
     t.each_with_index do |mois, i|
        s += concat(link_to_unless_current(mois, book_lines_path(book, "mois"=> i)))
    end
    s
  end
end

 


end
