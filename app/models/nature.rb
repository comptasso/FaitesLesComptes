# -*- encoding : utf-8 -*-
require 'strip_arguments'

# La classe Nature permet une indirection entre les comptes d'un exercice
# et le type de dépenses ou de recettes correspondant
# Le choix de relier Nature aux Account d'une Period, permet de 
# modifier les natures d'un exercice à l'autre (ainsi que le rattachement aux 
# comptes). 
# 
# Les natures sont reliées aux livres, ce qui permet de limiter les natures
# disponibles lorsqu'on écrit dans un livre aux seules natures de ce livre (et donc
# aussi de limiter les comptes accessibles pour un livre).
# 
#
class Nature < ActiveRecord::Base
 
  belongs_to :period
  belongs_to :account
  belongs_to :book

  has_many :compta_lines

  acts_as_list :scope=>[:period_id, :book_id]

  attr_accessible :name, :comment, :account, :account_id, :book_id 
  

  before_destroy :remove_from_list  #est défini dans le plugin acts_as_list

  strip_before_validation :name, :comment

  validates :period_id, :book_id, :presence=>true 
  validates :account_id, :fit_type=>true
  validates :name, presence: true,  :uniqueness=>{ :scope=>[:book_id, :period_id] }, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  

  scope :recettes, joins(:book).where('book_type = ?', 'IncomeBook').order(:position)
  scope :depenses, joins(:book).where('book_type = ?', 'OutcomeBook').order(:position)
  scope :without_account, where('account_id IS NULL')
  
  scope :within_period, lambda { |per| where('period_id = ?' , per.id)}

  before_destroy :ensure_no_lines

 
  # stat with cumul fournit un tableau comportant le total des lignes pour la nature
  # pour chaque mois plus un cumul de ce montant en dernière position
  # fait appel selon le cas à deux méthodes protected stat ou stat_filtered.
  def stat_with_cumul(destination_id = 0)
    s = (destination_id == 0) ? self.stat : self.stat_filtered(destination_id) 
    s << s.sum.round(2) # rajoute le total en dernière colonne
  end

  
  def in_out_to_s
    book.title
  end

 
  protected

  # Stat crée un tableau donnant les montants totaux de la nature pour chacun des mois de la période
  # pour toutes les destinations confondues
  def stat
    period.list_months.map do |m|
      compta_lines.mois_with_writings(m).sum('credit-debit').to_f.round(2)
    end
  end

  # Stat_filtered crée un tableau donnant les montants totaux de la nature pour chacun des mois de la période
  # pour une destination donnée
  def stat_filtered(destination_id)
    period.list_months.map do |m|
      compta_lines.mois_with_writings(m).where('destination_id=?', destination_id).sum('credit-debit').to_f.round(2)
    end
  end

  private

  def ensure_no_lines
    if compta_lines.empty?
      return true
    else
      errors.add(:base, 'Des écritures font référence à cette nature')
      return false
    end
  end

end
