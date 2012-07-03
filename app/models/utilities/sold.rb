# coding: utf-8


# Permet de rajouter des méthodes donnant le débit et le crédit à
# une date donnée (ou à la veille), ainsi que le solde.
# TODO il faudra voir comment on gère ça à l'usage avec beaucoup de lignes
# et plusieurs exercices.
#
module Utilities::Sold

  def cumulated_debit_before(date)
    self.lines.where('line_date < ?', date).sum(:debit)
  end

  def cumulated_credit_before(date)
    self.lines.where('line_date < ?', date).sum(:credit)
  end
  
  def sold_before(date = Date.today)
    cumulated_credit_before(date) - cumulated_debit_before(date)
  end

  def cumulated_debit_at(date)
    self.lines.where('line_date <= ?', date).sum(:debit)
  end

  def cumulated_credit_at(date)
    self.lines.where('line_date <= ?', date).sum(:credit)
  end

  def sold_at(date = Date.today)
    cumulated_credit_at(date) - cumulated_debit_at(date)
  end

  # donne un solde en prenant toutes les lignes du mois correspondant
  # à cette date; Le selector peut être une date ou une string
  # sous le format mm-yyyy
  # S'appuie sur le scope mois de Line
  def monthly_value(selector)
    if selector.is_a?(String)
      selector = Date.civil(selector[/\d{4}$/].to_i, selector[/^\d{2}/].to_i,1)
    end
    r = lines.select([:debit, :credit, :line_date]).mois(selector).sum('credit - debit') if selector.is_a? Date
    return r.to_f  # nécessaire car quand il n'y a pas de lignes, le retour est '0' et non 0
  end

 



end
