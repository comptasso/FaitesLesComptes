# coding: utf-8

module Compta


  # la classe RubrikResult permet de calculer le montant du résultat
  # donc prend le montant du compte 12, mais y ajoute le montant du résultat, lui
  # même fourni paor la méthode resultat de la classe Period par calcul du solde
  # des comptes de classe 7 et 6.
  class RubrikResult < Compta::RubrikLine


    # les valeurs d'un RubrikResult sont calculés à partir du compte 12
    # et du solde des comptes 6 et 7
    def set_value
      if account
        r = [account.sold_at(period.close_date) + period.resultat,0]
      else
        Rails.logger.warn "RubrikResult appelé par l'organisme #{period.organism.title} sans compte de résultats "
        r = [0,0]
      end
      @brut, @amortissement =  r
    end


    def previous_net(unused_period=nil)
      if period.previous_period?
        pp = period.previous_period
        acc = pp.accounts.find_by_number(select_num)
        s = acc ? acc.sold_at(pp.close_date) : 0
        s += pp.resultat
      else
        return 0.0
      end
      
    end
  end


end