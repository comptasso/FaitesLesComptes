# La clase Adherent::Writing est une classe dérivée de Writing et destinée
# à faire le lien entre le gem Adherent et l'application.
# 
# Le PaymentObserver qui observe les Adherent::Payments crée, modifie ou 
# supprime un élément Adherent::Writing.
# 
#  Cette classe est en fait la copie conforme de InOutWriting avec 
#  deux méthodes supplémentaires #payment et #member qui permettent
#  de faire le lien avec le payment. 
# 
module Adherent
class Writing < ::Writing
  validates :counter_line ,:counter_line_with_payment_mode=>true
  
  # revoie la ligne de recettes ou de dépenses de cette écriture
  #
  # S'il n'y en a pas, la construit
  def in_out_line
    cls  = compta_lines.select { |l| l.nature_id }
    cls.any? ? cls.first : compta_lines.build
  end

  alias counter_line support_line

  # retourne le long_name du compte de contrepartie
  #
  # C'est soit l'intitulé du compte 511 si 511 (Remise de chèques)
  # soit le nick_name de la caisse ou de la banque associée à ce compte.
  #
  # Pour les autres cas (en théorie cela ne devrait pas arriver), un avertissement
  # est émis et la méthode retourne le long_name du compte.
  def support
    acc = counter_line.account if counter_line && counter_line.account
    
    return acc.title if acc.number == '511'
    return acc.accountable.nickname if (acc.number =~ /^5[13]\d*/ )
    
    Rails.logger.warn "AdherentWriting#support appelée avec un compte qui n'est pas de classe 5 : account.number : #{acc.number}"
    acc.long_name # pour les autres cas
  end
  
  def payment
    Adherent::Payment.find_by_id(bridge_id)
  end
  
  
  # renvoie le membre ayant réalisé le payment correspondant à cette écriture
  #
  # Cette méthode est utile pour faire le lien entre les vues des livres et  
  # la vue des payments dans le module Adherent
  def member
    payment.member
  end
  
  protected
  
  def fill_date_piece
    self.date_piece = date
  end
  
  
end

end
