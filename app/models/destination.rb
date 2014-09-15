# -*- encoding : utf-8 -*-

require 'strip_arguments'

# La classe Destination permet d'avoir un axe d'analyse pour les données de la 
# comptabilité.
# 
# Il n'y a pas d'obligation d'avoir une ou des destinations. Les destinations 
# enregistrent les dépenses comme les recettes et donc permettent d'avoir des
# résultats économiques par destinations.
# 
class Destination < ActiveRecord::Base
  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold

  attr_accessible :name, :comment, :income_outcome, :sector_id

  belongs_to :organism
  belongs_to :sector
  has_many :compta_lines
  has_many :accounts, through: :compta_lines

  strip_before_validation :name, :comment

  validates :organism_id, :presence=>true
  validates :name, presence: true, uniqueness:true, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  

  default_scope order: 'name ASC'
  
  

  before_destroy :ensure_no_lines
  
  # Méthode exigée par Utilities::Sold
  # permet d'avoir toutes les méthodes de sold.... 
  # 
  # Ici, il faut filter les compta_lines sur les seuls comptes qui appartiennent
  # à l'exercice. 
  # 
  def cumulated_at(date, sens)
    exercice = organism.find_period(date)
    raise 'Aucun exercice trouvé pour cette date' unless exercice
    BigDecimal.new(Writing.sum(sens,
      :conditions=>['date <= ? AND destination_id = ? AND accounts.period_id = ?', date, id, exercice.id],
      :joins=>[:compta_lines=>:account]))
  end
  
  # Pour AnalyticalBalance lines. 
  # Donne les totaux débit et crédit des comptes qui ont eu des mouvements
  # à une date donnée.
  # 
  # Renvoie une collection de comptes avec le libellé, et les totaux débit
  # et crédit qui sont accessibles avec les méthodes t_debit et t_credit
  def ab_lines(period_id, from_date, to_date)
    {lines:lines(period_id, from_date, to_date),
      sector_name:sector.name,
      debit:debit,
      credit:credit}
  end
  
  
  private
  
  def lines(period_id, from_date, to_date)
    @lines ||= Account.joins(:compta_lines=>:writing).
      select([:number, :title, "SUM(debit) AS t_debit", "SUM(credit) AS t_credit"]).
        where('destination_id = ? AND period_id = ? AND date >= ? AND date <= ?',
        id, period_id, from_date, to_date).
        group(:title,:number)
  end
  
  def debit
    @lines.sum {|l| l.t_debit.to_d}
  end
  
  def credit
    @lines.sum {|l| l.t_credit.to_d}
  end
  
  

  def ensure_no_lines
    if compta_lines.empty?
      return true
    else
      errors.add(:base, 'Des écritures font référence à cette destination')
      return false
    end
  end

end
