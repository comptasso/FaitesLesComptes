# coding: utf-8

class OdBook < Book

  has_many :transfers, :dependent=>:destroy, :foreign_key=>'book_id'

  # nécessaire car la vue line affiche les comptes en fonction de income_outcome
  # TODO probablement à faire évoluer lors de la refonte du formulaire line pour
  # la partie compta
  def income_outcome
    true
  end


  def cumulated_at(date, dc)
    p = organism.find_period(date)
    val = p ? writings.joins(:compta_lines).period(p).where('date <= ?', date).sum(dc) : 0
    val.to_f # nécessaire car quand il n'y a aucune compa_lines, le retour est '0' et non 0 ce qui pose des
    # problèmes de calcul
  end
end
