#coding utf-8


module Compta

  #
  # La classe RubrikLine est une classe énumerable qui est construite par une
  # Rubrik à l'aide de RubrikParser pour déterminer les comptes
  # Elle donne un numéro de compte(qui est le premier compte qui l'a constitué,
  # un intitulé (idem), une valeur brute, un amortissement et un net
  #
  #  sens permet d'indiquer débit ou credit, ou actif et passif de façon
  #  à gérer les signes.
  #
  #  TODO transformer colon_1 en options qui peuvent être colon_2, debit, credit
  #  correspondant au fait que le montant s'inscrit dans la colonne des amortissements
  #  et provisions,
  #  que la valeur n'est retenue que s'il est débiteur
  #  que la valeur n'est retenue que s'il est créditeur
  #
  class RubrikLine

    attr_reader :brut, :amortissement, :select_num, :account

    def initialize(period, sens,  select_num, option= nil )
      @period = period
      @sens = sens
      @select_num = select_num
      @option = option
      @account = period.accounts.find_by_number(@select_num)
      set_value
    end

    
    # renvoie le libellé du compte. Si le compte n'existe pas pour cet exercice
    # essaye de trouver ce compte dans l'exercice précédent
    def title
      return @account.title if @account
      @period.previous_period.accounts.find_by_number(@select_num).title rescue nil
    end

    # calcule les valeurs brut et amortissements pour le compte
    # retourne [0,0] s'il n'y a pas de compte
    def set_value
      if @account
        s = @account.sold_at(@period.close_date)
        # prise en compte de la colonne provision ou amortissement
        r =  @option == :col2 ? [0, -s] : [s, 0]
        # l'option debit ne prend la valeur que si le solde est négatid
        r = [0,0] if @option == :debit && s > 0
        # l'otpion crédit ne prend la valeur que si le solde est positif
        r = [0,0] if @option == :credit && s < 0
        # prise en compte du sens
        if @sens == :actif || @sens == :debit
          r.collect! {|v| -v }
        end

      else
        r = [0,0]
      end
      @brut, @amortissement =  r
    end

    # retourne la valeur nette par calcul de la différence entre brut et amortissement
    def net
      @brut - @amortissement
    end

    # previous_net renvoie la valeur pour l'exercice précédent
    # il gère plusieurs cas puisque le compte peut exister pour un exercice et pas
    # pour l'autre.
    # Si le compte n'existe pas, revoie directement zero
    # s'il existe mais pas pour l'exercice précédent, renvoie 0
    # s'existe pour l'exercice précédent renvoie la valeur
    def previous_net
      if @period.previous_period?
        pp = @period.previous_period
        acc = pp.accounts.find_by_number(@select_num)
        s = acc ? acc.sold_at(pp.close_date) : 0
        s = -s if (@sens == :actif || @sens== :debit)
      else
        return 0.0
      end
    end

    # affiche la RibrikLine
    def to_s
      "#{@select_num}; #{title}; #{@brut}; #{@amortissement}; #{net}; #{previous_net}"
    end


  end
end