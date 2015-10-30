# -*- encoding : utf-8 -*-
require 'in_out_writings_helper'

module BankExtractLinesHelper
  include ModalsHelper
  include ModallinesHelper
  include InOutWritingsHelper
  include LtpsHelper # définit les ltps_actions
  # ces actions ont été mises dans un module car on en a besoin également
  # pour l'action create de modallines_controller.

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


