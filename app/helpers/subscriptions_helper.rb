# coding: utf-8


module SubscriptionsHelper
  
  # #sub_infos informe l'utilisateur des subscriptions qui sont en retard
  # renvoie un hash avec comme :text le message et comme :icon un icon_to
  # vers l'action proposée
  def sub_infos(sub)
    return nil unless sub.late?
    my = sub.first_to_write
    { 
      text:"L'écriture périodique '#{sanitize sub.title}' a des écritures à passer à partir de #{my.to_format('%B %Y')}",
      icon:icon_to('nouveau.png', subscription_path(sub), method: :post)
    }
      
    
  end
end
