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

  # Calcule les dates possibles pour un contrôle de caisse en fonction de l'exercice,
  # de la date du jour et des contrôles antérieurs.
  # on ne peut saisir un contrôle antérieur aux contrôles existants.
  # utilisé notamment par cash_control_controller#new
  def range_date_for_cash_control(period)
    last_cc = self.cash_controls.for_period(period).last(order: 'date ASC')
    min_date= last_cc ? [period.start_date, last_cc.date].max : period.start_date
    return min_date, [period.close_date, Date.today].min
  end



end
