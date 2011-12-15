# -*- encoding : utf-8 -*-
module CashLinesHelper

  def cashsubmenu_helper(cash, period)
   t=[]
   if period
     t= period.list_months
   else
    t=['Jan', 'Fév', 'Mars', 'Avril', 'Mai', 'Juin',' Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
   end

   content_tag :span do
     s=''
     t.each_with_index do |mois, i|
        s += concat(link_to_unless_current(mois, cash_lines_path(cash, "mois"=> i)))
    end
    s
  end
end
end
