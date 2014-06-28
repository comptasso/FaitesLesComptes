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
  
  
  belongs_to :sector
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
  
  
  def test_extract_lines(from_date, to_date)
    sql = <<-hdoc
      SELECT writings.book_id, writings.id, writings.date, writings.ref, writings.narration,
      cls.clid,
      cls.nname, cls.dname, cls.debit, cls.credit,
      support.pay_mode, acc_number, acc_title, bel_id
      FROM
      writings, 
      (SELECT compta_lines.id AS clid, compta_lines.writing_id as wid, 
      natures.name AS nname, destinations.name AS dname, 
      compta_lines.debit AS debit, compta_lines.credit AS credit
      FROM compta_lines 
      LEFT JOIN natures ON (natures.id = compta_lines.nature_id)
      LEFT JOIN destinations ON (destinations.id = compta_lines.destination_id)
      WHERE compta_lines.nature_id IS NOT NULL) as cls, 
      (SELECT compta_lines.writing_id AS wid, payment_mode AS pay_mode, 
      accounts.number AS acc_number, accounts.title AS acc_title, 
      bank_extract_lines.id AS bel_id

      FROM compta_lines 
      LEFT JOIN accounts ON accounts.id = compta_lines.account_id
      LEFT JOIN bank_extract_lines ON bank_extract_lines.compta_line_id = compta_lines.id
      WHERE nature_id IS NULL) as support
      WHERE 
      writings.book_id = '#{id}' AND
      cls.wid = writings.id AND support.wid = writings.id AND 
      writings.date >= '#{from_date}' AND 
      writings.date <= '#{to_date}'  
    hdoc
    res = IncomeOutcomeBook.connection.execute( sql.gsub("\n", ''))
    res
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
