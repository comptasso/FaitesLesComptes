class Cash < ActiveRecord::Base
   # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold

  include Utilities::JcGraphic



  def test_module(m)
    2000
  end
  # monthly_value est nécessaire pour le module Utilities::JcGraphic
  def monthly_value(mmyyyy)
    month= mmyyyy[/^\d{2}/]; year = mmyyyy[/\d{4}$/]
    sold Date.civil(year.to_i, month.to_i, 1).end_of_month
  end
  
  belongs_to :organism
  has_many :lines
  has_many :cash_controls

  # calcule le solde d'une caisse à une date donnée en partant du début de l'exercice 
  # qui inclut cette date
  # TODO en fait j'ai modifié ce comportement pour ne pas avoir ce problème de report
  # A réfléchir
  def sold(date=Date.today)
    # period=self.organism.find_period(date)
    ls= self.lines.where('line_date <= ?', date)
    date <= Date.today ? ls.sum(:credit)-ls.sum(:debit) : 0
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
