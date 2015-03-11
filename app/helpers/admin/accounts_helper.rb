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
  
  # Pour les actions sur un account dans la vue index
  def account_actions(account)
    html = icon_to 'modifier.png', edit_admin_period_account_path(@period, account)
    title = account_message(account)
    if title 
      html += image_tag('icones/nb_supprimer.png', title:title)
    else
      html += icon_to 'supprimer.png', [:admin,@period,account], 
                data: {confirm: 'Etes vous sûr ?'} , :method => :delete 
    end    
  end
  
  protected
  
    def account_message(account)
      return 'Compte relié à une caisse ou un compte bancaire' if account.accountable_id 
      return 'Compte utilisé par une nature' if account.nb_nats.to_i > 0
      return 'Compte ayant des écritures' if account.nb_cls.to_i > 0
      nil
    end



end