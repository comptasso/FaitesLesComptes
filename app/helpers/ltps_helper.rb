# -*- encoding : utf-8 -*-

# Module définissant uniquement les actions pour les lines_to_point 
# qui est inclus dans ModallinesHelper et dans BankExtractLinesHelper
# Ce pourquoi il a fallu en faire un module spécifique
module LtpsHelper
  include InOutWritingsHelper # définit actions_for_editable 
  # et actions_for_not_editable
  
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