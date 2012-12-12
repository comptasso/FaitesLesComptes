#coding utf-8


module Compta

  #
  # La classe RubrikLine est une classe énumerable qui est construite par une
  # Rubrik à l'aide de RubrikParser pour déterminer les comptes
  # Elle donne un numéro de compte(qui est le premier compte qui l'a constitué,
  # un intitulé (idem), une valeur brute, un amortissement et un net
  #
  # Sens permet d'indiquer débit ou credit, ou actif et passif de façon
  # à gérer les signes.
  #
  #  Options peut être qui peuvent être colon_2, debit, credit
  #  correspondant au fait que le montant s'inscrit dans la colonne des amortissements
  #  et provisions,
  #  que la valeur n'est retenue que s'il est débiteur
  #  que la valeur n'est retenue que s'il est créditeur
  #
  class RubrikLine

    include Utilities::ToCsv

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
      acc = @account || @period.previous_period.accounts.find_by_number(@select_num)
      "#{acc.number} - #{acc.title}" rescue "Erreur, compte #{@select_num} non trouve"
    end

    # calcule les valeurs brut et amortissements pour le compte
    # retourne [0,0] s'il n'y a pas de compte
    def set_value
       @brut, @amortissement =  brut_amort(@period, @select_num)
    end
    
    
    # retourne la valeur nette par calcul de la différence entre brut et amortissement
    def net
      @brut - @amortissement
    end

    # previous_net renvoie la valeur nette pour l'exercice précédent
    # 
    def previous_net
      if pp = @period.previous_period?
        net_value(pp, @select_num)
      else
        0.0
      end
    end

    def to_a
      [title, @brut, @amortissement, net, previous_net]
    end

    def to_actif
      [title, @brut, @amortissement, net, previous_net]
    end

    alias total_actif to_actif

    def to_passif
      [title, net, previous_net]
    end

    alias total_passif to_passif

    # indique la profondeur pour les fonctions récursives d'affichage
    # rubrik étant 0, rubrik_line est mis à  -1
    def depth
      -1
    end

#    # affiche la RubrikLine
#    def to_s
#      "#{@select_num}; #{title}; #{@brut}; #{@amortissement}; #{net}; #{previous_net}"
#    end

    def to_csv(options = {:col_sep=>"\t"})
      CSV.generate(options) do |csv|
        csv << [@select_num, title, @brut, @amortissement, net, previous_net]
      end.gsub('.', ',')
    end


  protected

    # méthode générique permettant de renvoyer la valeur nette suite à l'appel
    # de brut_amort, pour une périod donnée et pour un numéro de compte. Utilise l'option
    # de RubrikLine (colon_2, debit ou credit) pour calculer le montant à afficher dans le
    # document concerné.
    def net_value(period, select_num)
     r =  brut_amort(period, select_num)
     r[0] - r[1]
    end

    # renvoie la valeur du montant brut et de l'amortissement pour le compte
    # identifié par selet_num et pour l'exercice identifié par period
    def brut_amort(period, select_num)
      account = period.accounts.find_by_number(select_num)
      if account
        s = account.sold_at(period.close_date)
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
        r
    end
  end
end