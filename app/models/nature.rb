# -*- encoding : utf-8 -*-
class Nature < ActiveRecord::Base
 
  belongs_to :organism

  validates :organism_id, :presence=>true
  
   has_many :lines

   default_scope order: 'name ASC'
   scope :recettes, where('income_outcome = ?', true)
   scope :depenses, where('income_outcome = ?', false)

  before_destroy :ensure_no_lines

 # Stat crée un tableau donnant les montants totaux de la nature pour chacun des mois de la période
  def stat(period)
    org=period.organism
    period.nb_months.times.map do |m|
     d = org.lines.period_month(period,m).where('nature_id = ?', self.id).sum(:debit)
     c = org.lines.period_month(period,m).where('nature_id = ?', self.id).sum(:credit)
     c-d
     end
  end

  def stat_with_cumul(period)
    s =self.stat(period)
    s << s.sum
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
