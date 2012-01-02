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

  def range_date_for_cash_control(date=Date.today)
    period=self.organism.find_period(date)
    last_cc = self.cash_controls.for_period(period).last(order: 'date ASC')
    min_date= last_cc ? [period.start_date, last_cc.date].max : period.start_date
    return min_date, [period.close_date, Date.today].min
  end



end
