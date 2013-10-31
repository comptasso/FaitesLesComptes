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
  #  Options peut être colon_2, debit, credit
  #  correspondant au fait
  #  - colon_2 : le montant s'inscrit dans la colonne des amortissements
  #  et provisions,
  #  - debit : la valeur n'est retenue que si le solde est débiteur
  #  - credit : la valeur n'est retenue que si le solde est créditeur
  #
  class RubrikLine

    # include Utilities::ToCsv

    attr_reader :brut, :amortissement, :select_num, :account, :period, :sens, :option

    def initialize(period, sens,  select_num, option= nil )
      @period = period
      @sens = sens.to_sym
      @select_num = select_num
      @option = option
      @account = period.accounts.find_by_number(@select_num)
      set_value
    end

    
    # renvoie le libellé du compte. Si le compte n'existe pas pour cet exercice
    # essaye de trouver ce compte dans l'exercice précédent
    def title(unused_period = nil)
      acc = account || period.previous_period.accounts.find_by_number(@select_num)
      "#{acc.number} - #{acc.title}" rescue "Erreur, compte #{@select_num} non trouve"
    end
    
    
    
    def brut(unused_period = nil)
      @brut
    end
    
    def amortissement(unused_period = nil)
      @amortissement
    end

     
    
    # retourne la valeur nette par calcul de la différence entre brut et amortissement
    def net(unused_period = nil)
      brut - amortissement
    end

    # previous_net renvoie la valeur nette pour l'exercice précédent
    # 
    def previous_net(unused_period = nil)
      net_value(mise_en_forme(period.previous_account(account).final_sold)) rescue 0
    end

    # TODO ceci a été rajouté car les nouvelles Rubrik ont besoin de period
    # alors que ce n'est pas vrai pour les Compta::RubrikLines
    def to_actif(unused_period = nil)
      [title, brut, amortissement, net, previous_net]
    end

    alias total_actif to_actif
    alias to_a to_actif
    alias totals to_actif

    def to_passif(unused_period = nil)
      [title, net, previous_net]
    end

    alias total_passif to_passif

    # indique la profondeur pour les fonctions récursives d'affichage
    # rubrik_line est mis à  -1, ce qui l'identifie sans confusion
    # des rubriks qui peuvent avoir des profondeurs de 0 ou plus.
    def depth
      -1
    end

    # utilisé pour l'édition détaillée des folios ????
    # TODO voir si utilisé
#    def to_csv(options = {:col_sep=>"\t"})
#      CSV.generate(options) do |csv|
#        csv << [@select_num, title, net, previous_net]
#      end.gsub('.', ',')
#    end


    protected

    # Calcule les valeurs brut et amortissements pour le compte
    # retourne [0,0] s'il n'y a pas de compte
    #
    # Appelé lors de l'initialisation
    def set_value
      @brut, @amortissement =  brut_amort
    end

    

    # Renvoie un array comprenant en premier la valeur du montant brut et de l'amortissement pour le compte
    # identifié par selet_num et pour l'exercice identifié par period.
    #
    # Tient compte des options demandées pour préparer les valeurs brut et amort
    #
    def brut_amort
      return [0,0] unless account
      mise_en_forme(account.final_sold)
    end

    # Etant donné deux montants (brut et amortissements dans un tableau), calcule le net
    def net_value(arr)
      arr[0] - arr[1]
    end

    

    # Calule le brut et l'amortissement selon que l'on affiche
    # 4 colonnes (Actif) ou 2 colonnes (Passif et comptes de résultats)
    # et selon que l'on veut filtrer le crédit (pour le passif) et le débit(pour l'actif).
    # Car certains comptes sont présents à la fois dans un bilan actif et passif selon leur solde
    #
    #
    def mise_en_forme(value)
      result =  option == :col2 ? [0, -value] : [value, 0]
      # l'option debit ne prend la valeur que si le solde est négatif
      result = [0,0] if option == :debit && value > 0
      # l'option crédit ne prend la valeur que si le solde est positif
      result = [0,0] if option == :credit && value < 0
      # prise en compte du sens
      if sens == :actif || sens == :debit
        result.collect! {|v| v != 0.0 ? -v  : 0 } # ceci pour éviter des -0.0
      end
      result
    end




  end
end