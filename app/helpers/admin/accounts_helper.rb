# coding: utf-8
require 'options_for_association_select'

module Admin::AccountsHelper
  # traduction pour indiquer si le compte est utilisé ou non
  def t_used(account)
    account.used? ? 'Oui' : 'Non'
  end
  
  # pour indiquer le nom du secteur dans les compta avec secteurs;
  # Commun pour les comptes qui ne sont pas rattachés à un secteur.
  def secteur(account)
    account.s_name  || 'Commun'
  end



end