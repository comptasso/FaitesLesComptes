# coding: utf-8

module Compta::AccountsHelper
  
  #TODO : voir pour supprimer cette duplication avec méthode déja 
  #existante dans Admin::AccountsHelper 
  # traduction pour indiquer si le compte est utilisé ou non
  def t_used(account)
    account.used? ? 'Oui' : 'Non'
  end
end