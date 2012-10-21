# coding: utf-8


# Permet de rajouter des méthodes donnant le débit et le crédit à
# une date donnée (ou à la veille), ainsi que le solde et les
# monthly_values
#
# cumulated_at doit être défini dans les classes dans lesquelle on inclut ce module
# puisque toutes les méthodes définies ici le sont par cumulated_at
#
module Utilities::Sold


  # debit cumulé avant une date (la veille). Renvoie 0 si la date n'est incluse
  # dans aucun exercice
  def cumulated_debit_before(date)
    cumulated_debit_at(date - 1)
  end

  # crédit cumulé avant une date (la veille). Renvoie 0 si la date n'est incluse
  # dans aucun exercice
  def cumulated_credit_before(date)
    cumulated_credit_at(date - 1)
  end

  # solde d'une caisse avant ce jour (ou en pratique au début de la journée)
  def sold_before(date = Date.today)
    sold_at(date - 1)
  end

  # débit cumulé à une date (y compris cette date). Renvoie zero s'il n'y a
  # pas de périod et donc pas de compte associé à cette caisse pour cette date
  def cumulated_debit_at(date)
    cumulated_at(date, :debit)
  end

  # crédit cumulé à une date (y compris cette date). Renvoie 0 s'il n'y a
  # pas de périod et donc pas de comptes associé à cette caisse pour cette date
  def cumulated_credit_at(date)
    cumulated_at(date, :credit)
  end

  # solde à une date (y compris cette date). Renvoie nil s'il n'y a
  # pas de périod et donc pas de comptes pour cette date
  def sold_at(date)
    cumulated_credit_at(date) - cumulated_debit_at(date)
  end

  def movement(from, to, dc)
    cumulated_at(to, dc) - cumulated_at(from - 1 , dc)
  end



  # donne un solde en prenant toutes les lignes du mois correspondant
  # à cette date; Le selector peut être une date ou une string
  # sous le format mm-yyyy
  # S'appuie sur le scope mois de Line
  def monthly_value(selector)
    if selector.is_a?(String)
      selector = Date.civil(selector[/\d{4}$/].to_i, selector[/^\d{2}/].to_i,1)
    end
    r = sold_at(selector.end_of_month) - sold_before(selector.beginning_of_month)
    # r = lines.select([:debit, :credit, :line_date]).mois(selector).sum('credit - debit') if selector.is_a? Date
    return r.to_f  # nécessaire car quand il n'y a pas de lignes, le retour est '0' et non 0
  end

 



end
