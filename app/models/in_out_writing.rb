# coding: utf-8

# une InOutWriting est un type d'écriture qui permet d'enregistrer des lignes de dépenses et
# de recettes
#
# InOutWriting est généré par la saise d'une écriture sur un livre de recette ou de dépenses.
#
# Les écritures sont composées de deux lignes : une qui a forcément une nature
# et sa contrepartie sans nature mais avec un compte de classe 5 (Banque, Chèque à encaisser ou Caisse).
#
# On peut accéder à ces deux lignes par les méthodes #in_out_line
# et #support_line, également disponible par alias avec #counter_line
#
# La méthode #support permet de renvoyer le long_name du compte de la counterline (utilisé dans les éditions)
#
class  InOutWriting < Writing

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
    
    Rails.logger.warn "InOutWriting#support appelée avec un compte qui n'est pas de classe 5 : account.number : #{acc.number}"
    acc.long_name # pour les autres cas
  end
end
