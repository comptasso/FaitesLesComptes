# -*- encoding : utf-8 -*-

module Compta::SelectionsHelper

  def liste(condition)
    return 'Liste des écritures non verrouillées' if condition == 'unlocked'
  end
  
end
