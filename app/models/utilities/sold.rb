# coding: utf-8


# Permet de rajouter des méthodes donnant le débit et le crédit à
# une date donnée (ou à la veille), ainsi que le solde et les
# monthly_values
#
# cumulated_at doit être défini dans les classes dans lesquelle on inclut ce module
# puisque toutes les méthodes définies ici le sont par cumulated_at
#
module Utilities::Sold

  def cumulated_at(date, sens)
    raise 'Has to be implemented in child class'
  end

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
    cumulated_at(date, :debit).round 2
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

  # donne les mouvements entre deux dates (appelée from et to). Le sens
  # est fourni par le troisième argument (dc qui peut donc être :debit ou :credit
  #
  # Les mouvements incluent les deux bornes de dates.
  def movement(from, to, dc)
    (cumulated_at(to, dc) - cumulated_at(from - 1 , dc)).round 2
  end

  


end
