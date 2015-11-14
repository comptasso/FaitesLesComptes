# coding: utf-8

module Compta


  # La classe RubrikResult permet de calculer le montant du résultat
  # donc prend le montant du compte 12, mais y ajoute le montant du résultat, lui
  # même fourni par la méthode resultat de la classe Period par calcul du solde
  # des comptes de classe 7 et 6.
  #
  # Pour pouvoir gérer les comptes de comités d'entreprise, qui a 2 comptes de
  # résultats, il a été introduit la subtilité d'un compte de résultat relié
  # à un secteur.
  # Mais, du fait du réglement de l'ANC, il peut y avoir 2 comptes de résultats
  # pour un même secteur (1201 et 1291 par exemple, le premier pour un
  # résultat positif, le second pour un déficit.
  #
  # La méthode #set_value est celle qui traite ces point. Le premier cas est
  # celui d'un compte sectorisé et donc on prend la valeur au bilan d'ouverture
  # et on ajoute le montant du resultat sectorise.
  #
  # C'est cette deuxième méthode qui a été retravaillée pour prendre en compte
  # la subtilité 120x et 129x.
  #
  class RubrikResult < Compta::RubrikLine


    # les valeurs d'un RubrikResult sont calculés à partir du compte 12
    # et du solde des comptes 6 et 7. Ce dernier est donné par period.resultat
    def set_value
      Rails.logger.warn "RubrikResult appelé par l'organisme #{period.organism.title} sans compte de résultats " unless account
      super
#      puts "Le compte #{@account.inspect}, son secteur : #{@account.sector_id}, son numero #{@account.number}, son solde : #{@account.sold_at}"
      if @account && @account.sector_id
#        puts "Dans la brance compte sectorisé - valeur de @brut : #{@brut}"
        @brut += resultat_sectorise
      elsif @account && @account.number == '12'
#        puts "Dans la brance compte 12 non sectorisé - valeur de @brut : #{@brut}"
        @brut += resultat_non_sectorise
      else # traite le cas ou un compte 12XX n'aurait pas été sectorisé
#        puts "Dans la branche else - valeur de @brut : #{@brut}"
        @brut += 0
      end
#      puts "fin de méthode @brut = #{@brut}"
      if period.previous_period_open?
#        puts "on rajoute previous_net donc montant : #{previous_net}"
        @brut += previous_net
      end
#      puts "après rajout de previous net @brut = #{@brut}"
      return @brut, @amortissement = BigDecimal.new(0)
    end


    def previous_net(unused_period=nil)
      return 0.0 unless period.previous_period?
      return 0.0 unless acc = previous_account # défini dans RubrikLine
      cr = Compta::RubrikResult.new(period.previous_period, 'passif', acc.number)
      cr.brut
    end

    # Calcul de la valeur brute.
    # Puis prise en compte du type de compte 12, soit il est de type 120x
    # et on ne retient le résultat que s'il est positif,
    # soit il est de type 129x et c'est l'inverse.
    def resultat_sectorise
      res = period.resultat(@account.sector_id)
      if @account.number =~ /^120.*/
        return res >= 0 ? res : 0.0
      elsif @account.number =~ /129.*/
        return res >= 0 ? 0.0 : res
      end
      Rails.logger.warn "Calcul du resultat appelé pour #{@account.number}
        qui n'est ni de la forme 120x, ni 129y"
      0 # cas non prévu où le compte 12 ne serait pas un 120 ou un 129
    end

    def total_resultat_sectorise
      sacs = period.accounts.where('number LIKE ? AND sector_id IS NOT NULL', '12%')
      # pour éviter de prendre en compte 2 fois le résultat lorsqu'il y a 2
      # comptes de résultats rattachés au même secteur (1201 et 1291 par exemple)
      # ce qui est normalement le cas pour gérer les résultats positifs et
      # négatifs
      sacs.to_a.uniq! {|i| i.sector_id}
      sacs.inject(0) { |sum, acc| sum + period.resultat(acc.sector_id)}
    end

    def resultat_non_sectorise
      period.resultat - total_resultat_sectorise
    end

  end

end
