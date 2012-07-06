# -*- encoding : utf-8 -*-


# La classe Nature permet une indirection entre les comptes d'un exercice
# et le type de dépenses ou de recettes correspondant
# Le choix de relier Nature aux Account d'une Period, permet de 
# modifier les natures d'un exercice à l'autre (ainsi que le rattachement aux 
# comptes). 
# 
#
class Nature < ActiveRecord::Base
 
  belongs_to :period
  belongs_to :account

  validates :period_id, :presence=>true
  validates :name, :presence=>true
  validates :name, :uniqueness=>{ :scope=>[:income_outcome, :period_id] }
  validates :income_outcome, :inclusion => { :in => [true, false] }

  # TODO rajouter avec un if pour coller avec le type de compte
  # validates :account_ids, :fit_type=>true retiré car on ne crée plus l'assoc avec le compte dans le form nature
  
  has_many :lines


  scope :recettes, where('income_outcome = ?', true).order('name ASC')
  scope :depenses, where('income_outcome = ?', false).order('name ASC')
  scope :without_account, where('account_id IS NULL')

  before_destroy :ensure_no_lines

 
  # stat with cumul fournit un tableau comportant le total des lignes pour la nature
  # pour chaque mois plus un cumul de ce montant en dernière position
  # fait appel selon le cas à deux méthodes protected stat ou stat_filtered.
  def stat_with_cumul(destination_id = 0)
    s = (destination_id == 0) ? self.stat : self.stat_filtered(destination_id)
    s << s.sum

  end

  
  def in_out_to_s
    self.income_outcome ? 'Recettes' : 'Dépenses'
  end

 
  protected

  # Stat crée un tableau donnant les montants totaux de la nature pour chacun des mois de la période
  # pour toutes les destinations confondues
  def stat
    period.list_months('%m%Y').map do |m|
      lines.month(m).sum('credit-debit').to_f
    end
  end

  # Stat_filtered crée un tableau donnant les montants totaux de la nature pour chacun des mois de la période
  # pour une destination donnée
  def stat_filtered(destination_id)
    period.list_months('%m%Y').map do |m|
      lines.month(m).where('destination_id=?', destination_id).sum('credit-debit').to_f
    end
  end

  private

  def ensure_no_lines
    if lines.empty?
      return true
    else
      errors.add(:base, 'Des écritures font référence à cette nature')
      return false
    end
  end

end
