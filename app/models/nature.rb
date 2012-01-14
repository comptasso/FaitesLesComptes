# -*- encoding : utf-8 -*-
class Nature < ActiveRecord::Base
 
  belongs_to :organism
  has_and_belongs_to_many :accounts

  validates :organism_id, :presence=>true
  validates :account_ids, :fit_type=>true
  
   has_many :lines

   default_scope order: 'name ASC'
   scope :recettes, where('income_outcome = ?', true)
   scope :depenses, where('income_outcome = ?', false)

  before_destroy :ensure_no_lines

 
 # stat with cumul fournit un tableau comportant le total des lignes pour la nature
 # pour chaque mois plus un cumul de ce montant en dernière position
 # fait appel selon le cas à deux méthodes protected stat ou stat_filtered.
  def stat_with_cumul(period, destination_id = 0)
    s = (destination_id == 0) ? self.stat(period) : self.stat_filtered(period, destination_id)
    s << s.sum

  end

  # trouve le compte de l'exercice auquel est rattaché cette nature
  # TODO faire un test de cohérence, il ne doit y en avoir qu'un
  def account_id(period)
    self.accounts.where('period_id = ?', period.id).first.id
  rescue
    nil
  end

   # vérifie si la nature est rattachée à un compte
  def linked_to_account?(period)
    self.account_id(period).is_a?(Account) ? true : false
  end

 
   protected

  # Stat crée un tableau donnant les montants totaux de la nature pour chacun des mois de la période
  # pour toutes les destinations confondues
  def stat(period)
    org=period.organism
    period.nb_months.times.map do |m|
     d = org.lines.period_month(period,m).where('nature_id = ?', self.id).sum(:debit)
     c = org.lines.period_month(period,m).where('nature_id = ?', self.id).sum(:credit)
     c-d
     end
  end

  # Stat crée un tableau donnant les montants totaux de la nature pour chacun des mois de la période
  # pour une destination donnée
  def stat_filtered(period, destination_id)
    org=period.organism
    period.nb_months.times.map do |m|
     d = org.lines.period_month(period,m).where('nature_id = ?', self.id).where('destination_id=?', destination_id).sum(:debit)
     c = org.lines.period_month(period,m).where('nature_id = ?', self.id).where('destination_id=?', destination_id).sum(:credit)
     c-d
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
