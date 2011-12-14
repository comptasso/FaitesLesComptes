# -*- encoding : utf-8 -*-
module BankLinesHelper

  def banksubmenu_helper(bank_account, period)
   t=[]
   if period
     t= period.list_months
   else
    t=['Jan', 'Fév', 'Mars', 'Avril', 'Mai', 'Juin',' Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
   end

   content_tag :span do
     s=''
     t.each_with_index do |mois, i|
        s += concat(link_to(mois, bank_account_bank_lines_path(bank_account, "mois"=> i)))
    end
    s
  end
end
end
