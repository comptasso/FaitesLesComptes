# coding: utf-8

module Compta

  # Une rubrique comprend un titre et une série de numéros de comptes
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
  #  On créé la classe avec comme argument period, title, sens (:actif ou :passif), et un string
  #  de numéros de comptes '20 201 206 207 208'
  #
  #  ON utilise quelques symboles pour identifier les comptes que l'on souhaite avoir
  #  
  #  -280 signifie que le solde sera à prendre dans la seconde colonne (amortissements ou provisions)
  #  !201 signifie que ce compte ne doit pas être repris
  #  47C ou 47D signifie que le compte n'est pris que s'il est créditeur ou débiteur
  #  
  #
  class Rubrik

    attr_accessor :title

    def initialize(period, title, sens, numeros)
      @period = period
      @title = title.to_s
      @numeros = numeros
      @sens = sens
    end

    # indique si la rubrique est le résultat de l'exercice (le compte 12).
    # ceci pour ne pas afficher le détail de tous les comptes 6 et 7
    # lorsque l'on affiche le détail du passif
    def resultat?
      '12'.in?(@numeros)
    end

    # pour chacun des comptes construit un tableau
    # avec le numéro de compte, l'intitulé, le solde dans le sens demandé
    # ou l'inverse du solde si le sens est contraire
    # Une particularité est le compte 12 (résultat) qui dans la nomencalture
    # est indiqué comme '12, 7, -6' et pour lequel lines, ne doit renvoyer
    # qu'un compte 12
    #
    def lines

        @lines ||= Compta::RubrikParser.new(@period, @sens, @numeros).rubrik_lines
      
    end

    # retourne la ligne de total de la rubrique
    def totals
      [@title, brut, amortissement, net, previous_net]
    end

    def totals_prefix(prefix = 'Total ')
      v = totals
      v[0] = prefix + v[0].to_s
      v
    end

    alias total_actif totals

    def total_passif
      [@title, net, previous_net]
    end

    # crée un array avec le titre suivi de l'ensemble des lignes suivi de la ligne de total
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

    # la profondeur (depth) d'une rubrique est 0
    # cette méthode existe pour pouvoir définir la profondeur
    # des Compta::Rubriks
    def depth
      0
    end

    

    

    
  end

  
end
