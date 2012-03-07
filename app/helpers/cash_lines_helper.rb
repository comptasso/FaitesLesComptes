# -*- encoding : utf-8 -*-
module CashLinesHelper

  def cashsubmenu_helper(cash, period)
    content_tag :span do
      s=''
      period.list_months('%b').each_with_index do |mois, i|
        s +=concat(  content_tag(:span) { link_to_unless_current(mois, cash_cash_lines_path(cash, "mois"=> i)) } )
      end
      s
    end
  end
end
