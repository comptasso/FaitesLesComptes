# -*- encoding : utf-8 -*-

module BankExtractLinesHelper
  def details_for_popover(bel)
    content_tag :table do
      html = "<tr><td>Date</td><td>Libellé</td><td>Débit</td><td>Crédit</td></tr>"
      bel.lines.each do |l|
        html << content_tag(:tr) do
            "<td>#{l l.line_date}</td><td>#{sanitize l.narration}</td><td>#{debit_credit l.debit}</td><td>#{debit_credit l.credit}</td>"
        end
      end
      html.html_safe
    end
  end
end
