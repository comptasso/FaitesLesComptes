# coding: utf-8


module SubscriptionsHelper
  
  # #sub_infos informe l'utilisateur des subscriptions qui sont en retard
  # renvoie un hash avec comme :text le message et comme :icon un icon_to
  # vers l'action proposée
  def sub_infos(sub)
    return nil unless sub.late?
    my = sub.first_to_write
    nb = sub.nb_late_writings
    { 
      text:"L'écriture périodique '#{sanitize sub.title}' a #{pluralize(nb, 'écriture')} à passer (à partir de #{my.to_format('%B %Y')}) ",
      icon:icon_to('nouveau.png', subscriptions_path(subscription:{:id=>sub.id}),
        method: :post, remote:true, id:"subscription_#{sub.id}")
    }
  end
    
    # pluralize de rails mais sans le nombre pour pouvoir accorder
    # les phrases.
    #
    # Par exemple :  
    # pluralize(count, 'écriture') + jc_pluralize(count, 'a', 'ont') + 
    #   jc_pluralize(count, 'générée)
    # pourra donner 1 écriture a été générée ou 
    #   2 écritures ont été générées
    def jc_pluralize(count, singular, plural=nil)
      if count == 1 || count == 0
        singular
      else
        plural || singular.pluralize
      end
    end
      
    
  
end
