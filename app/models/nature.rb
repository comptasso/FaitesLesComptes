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


   scope :recettes, where('income_outcome = ?', true)
   scope :depenses, where('income_outcome = ?', false)
   scope :without_account, where('account_id IS NULL')

  before_destroy :ensure_no_lines

 
 # stat with cumul fournit un tableau comportant le total des lignes pour la nature
 # pour chaque mois plus un cumul de ce montant en dernière position
 # fait appel selon le cas à deux méthodes protected stat ou stat_filtered.
  def stat_with_cumul(period, destination_id = 0)
    s = (destination_id == 0) ? self.stat(period) : self.stat_filtered(period, destination_id)
    s << s.sum

  end

  
  def in_out_to_s
    self.income_outcome ? 'Recettes' : 'Dépenses'
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
