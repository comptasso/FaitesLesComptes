# coding: utf-8

# les livres de recettes et de dépenses
class IncomeOutcomeBook < Book

  has_many :in_out_writings,  foreign_key:'book_id'
  has_many :adherent_writings,  foreign_key:'book_id'

  has_many :in_out_lines, :through=>:in_out_writings, :source=>:compta_lines, foreign_key:'writing_id', :conditions=>['nature_id IS NOT ?', nil]

  # extrait les lignes entre deux dates. Cette méthode ne sélectionne pas sur un exercice.
  def extract_lines(from_date, to_date)
    in_out_lines.where('writings.date >= ? AND writings.date <= ?', from_date, to_date).order('writings.date')
  end

  # l'affichage des montants et des lignes dans la vue ne doit prendre en
  # compte que les lignes qui ont une nature et être limité à l'exercice.
  def cumulated_at(date, dc)
    p = organism.find_period(date)
    val = p ? writings.joins(:compta_lines).period(p).where('date <= ? AND nature_id IS NOT ?', date, nil).sum(dc) : 0
    val.to_f # nécessaire car quand il n'y a aucune compa_lines, le retour est '0' et non 0 ce qui pose des
    # problèmes de calcul
  end
end
