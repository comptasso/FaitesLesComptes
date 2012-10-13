# coding: utf-8

# les livres de recettes et de dépenses
class IncomeOutcomeBook < Book

  # l'affichage des montants et des lignes dans la vue ne doit pas prendre en
  # compte les lignes de base, donc celles qui ont une nature
  def cumulated_at(date, dc)
    p = organism.find_period(date)
    val = p ? writings.joins(:compta_lines).period(p).where('date <= ? AND nature_id IS NOT ?', date, nil).sum(dc) : 0
    val.to_f # nécessaire car quand il n'y a aucune compa_lines, le retour est '0' et non 0 ce qui pose des
    # problèmes de calcul
  end
end
