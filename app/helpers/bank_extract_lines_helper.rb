# -*- encoding : utf-8 -*-
require 'in_out_writings_helper'

module BankExtractLinesHelper
  include ModalsHelper
  include ModallinesHelper

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

  # les actions pour line_to_point
  def ltps_actions(ltp, editable=true)
    # on sait déja que la ligne n'est pas pointée, donc ce qui doit encore
    # être vérifiée est que la ligne n'est pas verrouillée, ni déposée (ce
    # dernier point étant théoriquement impossible d'ailleurs, puisqu'un
    # chèque à encaisser n'entre pas dans la catégorie des écritures à pointer.
    html  = ''
    html += yield if block_given?
    w = ltp.writing
    if  (ltp.locked? || ltp.deposited?)
      html += actions_for_not_editable(w, false)
    else
      html += actions_for_editable(w, false)
    end
    html.html_safe
  end

end


