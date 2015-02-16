module Compta::MenusHelper
  
  # objectif indiquer si la classe du droppdown menu doit être active
  # le premier dropdown doit être actif pour les éditions du 
  # plan comptable, de la balance, d'un listing de compte, d'un grand livre,
  # du FEC, et de la balance analytique
  # 
  # Cette détection est faite à partir du nom de controller et de l'action
  #
  def editions_active?
    return 'active' if controller.controller_name == 'accounts' 
    return 'active' if controller.controller_name == 'balances' 
    return 'active' if controller.controller_name == 'analytical_balances' 
    return 'active' if controller.controller_name == 'listings' 
    return 'active' if controller.controller_name == 'general_books' 
    return 'active' if controller.controller_name == 'fecs' 
    return ''
  end
  
  def documents_active?
    return 'active' if controller.controller_name == 'sheets' 
    return 'active' if controller.controller_name == 'two_periods_balances' 
    return 'active' if controller.controller_name == 'nomenclatures' 
    return ''
  end
  
  
end