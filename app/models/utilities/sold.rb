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

  alias debit_before cumulated_debit_before

  # crédit cumulé avant une date (la veille). Renvoie 0 si la date n'est incluse
  # dans aucun exercice
  def cumulated_credit_before(date)
    cumulated_credit_at(date - 1)
  end

  alias credit_before cumulated_credit_before

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
    cumulated_at(date, :credit).round 2
  end

  

  # solde à une date (y compris cette date). Renvoie nil s'il n'y a
  # pas de périod et donc pas de comptes pour cette date
  def sold_at(date)
    (cumulated_credit_at(date) - cumulated_debit_at(date)).round 2
  end

  def movement(from, to, dc)
    (cumulated_at(to, dc) - cumulated_at(from - 1 , dc)).round 2
  end

  



  # donne un solde en prenant toutes les lignes du mois correspondant
  # à cette date; Le selector peut être une date ou une string
  # sous le format mm-yyyy
  # S'appuie sur le scope mois de Line
  #
  # Le calcul se fait en déduisant le solde à la fin du mois du solde à la
  # fin du mois précédent.
  #
  # Cas particulier, si on est en début d'exercice : on ne retire pas le solde du mois
  # précédent
  def monthly_value(selector)
    Rails.logger.debug "monthly_value appelée avec #{selector} comme argument sur #{title}"
    selector = string_to_date(selector) if selector.is_a?(String)
    r = sold_at(selector.end_of_month)
    # on ne déduit le solde antérieur que si on n'est pas au début de l'exercice
    r -= sold_before(selector.beginning_of_month) unless Period.beginning_of_period?(selector.beginning_of_month)
    r.to_f.round 2  # nécessaire car quand il n'y a pas de lignes, le retour est '0' et non 0
  end


  def string_to_date(selector)
    Date.civil(selector[/\d{4}$/].to_i, selector[/^\d{2}/].to_i,1)
  rescue
    raise ArgumentError, "#{selector} n' pas pu être converti en date"
  end

 



end
