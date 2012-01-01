# -*- encoding : utf-8 -*-
module CashLinesHelper

  def cashsubmenu_helper(cash, period)
   t=[]
   if period
     t= period.list_months
   else
     t=['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',' Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
   end
 content_tag :span do
     s=''
     t.each_with_index do |mois, i|

        u =  content_tag :span do
             link_to_unless_current(mois, organism_cash_cash_lines_path(@organism,cash, "mois"=> i))
        end
        s += concat(u)
    end
    s
  end


   
end
end
