# coding: utf-8

module Compta::LinesHelper

 def sub_helper(account, period)
    content_tag :span do
      s=''
      period.list_months.each_with_index do |mois, i|
        u =  content_tag :span do
          link_to_unless_current(mois, compta_account_lines_path(account, "mois"=> i))
        end
        s += concat(u)
      end
      s
    end
  end
end
