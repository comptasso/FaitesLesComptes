class Cash < ActiveRecord::Base
  belongs_to :organism
  has_many :lines
  has_many :cash_controls

  # calcule le solde d'une caisse à une date donnée en partant du début de l'exercice 
  # qui inclut cette date
  def sold(date=Date.today)
    period=self.organism.find_period(date)
    ls= self.lines.where('line_date >= ? AND line_date <= ?', period.start_date, date)
    return ls.sum(:credit)-ls.sum(:debit)
  end



end
