# coding: utf-8

module Compta

  class RubrikResult < Compta::RubrikLine


    # les valeurs d'un RubrikResult sont calculés à partir du compte 12
    # et du solde des comptes 6 et 7
    def set_value
      if @account
        r = [@account.sold_at(@period.close_date) + @period.resultat,0]
      else
        r = [0,0]
      end
      @brut, @amortissement =  r
    end


    def previous_net
      if @period.previous_period?
        pp = @period.previous_period
        acc = pp.accounts.find_by_number(@select_num)
        s = acc ? acc.sold_at(pp.close_date) : 0
        s += pp.resultat
      else
        return 0.0
      end
      
    end
  end


end