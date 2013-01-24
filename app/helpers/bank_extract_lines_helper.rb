# -*- encoding : utf-8 -*-

module BankExtractLinesHelper
  def details_for_popover(bel)
    html =  []
    bel.compta_lines.each do |l|
      html << content_tag(:ul) do
        content_tag(:li) do
          "#{l l.date} - #{sanitize l.narration} - #{two_decimals l.debit} - #{two_decimals l.credit}</td>".html_safe
        end
      end
    end
    html
  end

  def details_title
    "Détail des lignes"
  end
end



# <tr><td>Date</td><td>Libellé</td><td>Débit</td><td>Crédit</td></tr>"
