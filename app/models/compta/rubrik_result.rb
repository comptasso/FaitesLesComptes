# coding: utf-8

module Compta


  # la classe RubrikResult permet de calculer le montant du résultat
  # donc prend le montant du compte 12, mais y ajoute le montant du résultat, lui
  # même fourni paor la méthode resultat de la classe Period par calcul du solde
  # des comptes de classe 7 et 6.
  class RubrikResult < Compta::RubrikLine


    # les valeurs d'un RubrikResult sont calculés à partir du compte 12
    # et du solde des comptes 6 et 7. Ce dernier est donné par period.resultat
    def set_value
      Rails.logger.warn "RubrikResult appelé par l'organisme #{period.organism.title} sans compte de résultats " unless account
      super
      if @account.sector_id
        @brut += resultat_sectorise(@account.sector_id)
      else
        @brut += resultat_non_sectorise
      end
      return @brut, @amortissement
    end


    def previous_net(unused_period=nil)
      if period.previous_period?
        pp = period.previous_period
        acc = pp.accounts.find_by_number(select_num)
        s = acc ? acc.sold_at(pp.close_date) : 0
        s += pp.resultat(acc.sector_id)
      else
        return 0.0
      end
    end
    
    protected
    
    # calcul de la valeur brute
    # une méthode indiquant s'il y a des comptes 12 sectorisés
    def resultat_sectorise(sector_id)
      period.resultat(@account.sector_id)
    end 
    
    def total_resultat_sectorise
      sacs = period.accounts.where('number LIKE ? AND sector_id IS NOT NULL', '12%')
      sacs.inject { |s| resultat_sectorise(s.sector_id)}
    end
    
    def resultat_non_sectorise
      period.resultat - total_resultat_sectorise
    end
    
    
  end

end