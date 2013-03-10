# -*- encoding : utf-8 -*-

module BankExtractLinesHelper

  # Affiche le détail des lignes d'un extrait de compte lorsque celles-ci sont regroupées
  def details_for_popover(bel)
    html =  []
    bel.compta_lines.each do |l|
      html << content_tag(:ul) do
        content_tag(:li) do
          "#{l l.date} - #{sanitize l.narration} - #{two_decimals l.credit} - #{two_decimals l.debit}</td>".html_safe
        end
      end
    end
    html
  end

  
end



# <tr><td>Date</td><td>Libellé</td><td>Débit</td><td>Crédit</td></tr>"
