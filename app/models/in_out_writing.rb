# coding: utf-8

# une InOutWriting est un type d'écriture qui permet d'enregistrer des lignes de dépenses et
# de recettes
# InOutWriting est généré par la saise d'une écriture sur un livre de recette ou de dépenses.
# Les écritures sont composées de deux lignes : une qui a forcément une nature
# et sa contrepartie sans nature mais avec un compte de classe 5 (Banque, Chèque à encaisser ou Caisse).
# ON peut accéder à ces deux lignes par les méthodes in_out_line
# et counter_line
#
# support permet de renvoyer le long_name du compte de la counterline (utilisé dans les éditions)
#
class  InOutWriting < Writing
  
  # revoie la ligne de recettes ou de dépenses de cette écriture
  def in_out_line
    compta_lines.select { |l| l.nature_id != nil }.first 
  end

  alias counter_line support_line

  # retourne le long_name du compte de contrepartie
  def support
    acc = counter_line.account if counter_line && counter_line.account
    puts acc.number
    return acc.title if acc.number == '511'
    return acc.accountable.nickname if (acc.number =~ /^5[13]\d*/ )
    
    Rails.logger.warn "InOutWriting#support appelée avec un compte qui n'est pas de classe 5 : account.number : #{acc.number}"
    acc.long_name # pour les autres cas
  end
end
