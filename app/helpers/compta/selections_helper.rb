# -*- encoding : utf-8 -*-

module Compta::SelectionsHelper

  def liste(condition)
    'Liste des écritures non verrouillées' if @select_method == :unlocked
  end
  
end
