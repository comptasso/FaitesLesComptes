# coding: utf-8

# Représente les livres de recettes et de dépenses. 
#
# Ces livres enregistrent les écritures de recettes et de dépenses (InOutWriting)
# mais aussi les écritures (toujours de recettes et de dépenses) qui viennent d'un 
# gem complémentaire (actuellement seulement Adherent). D'où la présence de 
# has_many adherent_writings.
# 
# Chaque écriture Writing (ou ses héritiers) a au moins deux compta_lines. La compta_line
# principale étant celle qui enregistre une nature. 
# 
# Le has_many :in_out_lines, :through=>:writings permet de récupérer ces compta_lines grâce
# à la condition Nature IS NOT NULL.
#
class IncomeOutcomeBook < Book
  
  attr_accessible :sector_id
  
  has_many :writings,  foreign_key:'book_id'
  has_many :natures, foreign_key:'book_id'
 
  has_many :in_out_writings,  foreign_key:'book_id'
  has_many :adherent_writings,  foreign_key:'book_id', class_name:'Adherent::Writing'

  has_many :in_out_lines, :through=>:writings, :source=>:compta_lines, foreign_key:'writing_id', :conditions=>['nature_id IS NOT ?', nil]

  has_one :export_pdf, :as=>:exportable 
  
  # extrait les lignes entre deux dates. Cette méthode ne sélectionne pas sur un exercice.
  def extract_lines(from_date, to_date)
    in_out_lines.where('writings.date >= ? AND writings.date <= ?', from_date, to_date).order('writings.date')
  end

  # surchargée car l'affichage des montants et des lignes dans la vue ne doit prendre en
  # compte que les lignes qui ont une nature et être limité à l'exercice.
  def cumulated_at(date, dc)
    p = organism.find_period(date)
    val = p ? writings.joins(:compta_lines).period(p).where('date <= ? AND nature_id IS NOT ?', date, nil).sum(dc) : 0
    val.to_f # nécessaire car quand il n'y a aucune compa_lines, le retour est '0' et non 0 ce qui pose des
    # problèmes de calcul
  end
end
