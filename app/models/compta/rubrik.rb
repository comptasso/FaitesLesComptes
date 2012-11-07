# coding: utf-8

module Compta

  # Une rubrique comprend une position, un titre et une série de numéros de comptes
  # Chaque numéro de compte doit être affecté d'un sens 'debit' ou 'credit'
  #
  # Lorsque Rubrik donne les soldes, elle cumule les soldes des sous comptes
  # de la rubrique.
  #
  # Elle affiche un moins si le solde est de sens contraire au sens recherché
  #
  #  Par exemple Pour la rubrique Immobilisations incorporelles
  #  les comptes :
  #  Immo incorporelles 20
  #  Mais aussi Frais d'établissement 201 debit
  #  Droit au bail 206
  #  Fonds commercial 207
  #  Autres immobilisations incorporelles 208
  #  amortissement des frais d'établissement 2801 credit
  #
  #  La classe doit afficher les différentes lignes de comptes mais sans faire de doublon
  #
  #  On créé la classe avec comme argument period, title, sens (:actif ou :passif), et un array
  #  de numéros de comptes ['20','201','206', '207', '208']
  #
  #  ON utilise quelques symboles pour identifier les comptes que l'on souhaite avoir
  #  '20%' veut dire le compte 20 et tous ceux qui commencent par 20. Ceci est par défaut
  #  '-280' signifie que le solde sera à prendre dans la seconde colonne (amortissements ou provisions)
  #  
  #
  class Rubrik

    attr_accessor :title

    def initialize(period, title, sens, *numeros)
      @period = period
      @title = title
      @numeros = numeros
      @sens = sens
    end

    # pour chacun des comptes construit un tableau
    # avec le numéro de compte, l'intitulé, le solde dans le sens demandé
    # ou l'inverse du solde si le sens est contraire
    def lines
      # compact supprime les valeurs nil
      @lines ||= Compta::RubrikParser.new(@period, @sens, *@numeros).rubrik_lines
    end

    # retourne la ligne de total de la rubrique
    def totals
      ["Total #{@title}", brut, amortissement, net, previous_net]
    end

    
    def complete_list
      [@title] + lines + totals
    end


    def brut
      @brut ||= lines.sum(&:brut)
    end

    def amortissement
      @amortissement ||= lines.sum(&:amortissement)
    end

    alias depreciation amortissement

    def net
      @net ||= (brut - amortissement) rescue 0.0
    end

    def previous_net
      @previous_net ||= lines.sum(&:previous_net)
    end

    

    

    
  end

  
end
