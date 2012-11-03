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
  #  La classe doit afficher les différentes lignes de comptes mais snas faire de doublon
  #  On créé la classe avec comme argument period, title, :debit ou :credit, et un array
  #  de numéros de comptes ['20','201','206', '207', '208']
  #
  #  ON utilise quelques symboles pour identifier les comptes que l'on souhaite avoir
  #  '20%' veut dire le compte 20 et tous ceux qui commencent par 20
  #  '-280' signifie que le solde sera à prendre dans la seconde colonne (amortissements ou provisions)
  #  
  #
  class Rubrik

    attr_accessor :title

    def initialize(period, title, numeros)
      @period = period
      @title = title
      
      @numeros = numeros
      
    end

    # pour chacun des comptes construit un tableau
    # avec le numéro de compte, l'intitulé, le solde dans le sens demandé
    # ou l'inverse du solde si le sens est contraire
    def values
      # compact supprime les valeurs nil
      @values ||= @numeros.collect{|n| account_values(n) }.compact
    end

    # retourne la ligne de total de la rubrique
    def totals
      t2 = values.sum {|v| v[2]}
      t3 = values.sum {|v| v[3]}
      diff = t2-t3 rescue 0.0
      ["Total #{@title}", t2, t3, diff]
    end

    protected

    # Construit une ligne du tableau des valeurs  
    # reprenant le numero de compte, son titre, son solde dans la première ou la seconde
    # colonne selon son sens.
    # retourne nil si parse_number ne trouve pas de compte
    #
    # Dans le cas où il y a plusieurs comptes regroupés, prend en compte le premier numéro et son libéllé
    def account_values(num)
      unless (pn = parse_numbers(num)).empty?
        s = pn.inject(0) {|t , acc| t + acc.sold_at(@period.close_date) }
        r = (num =~ /^-.*/) ? [0, -s] : [s, 0]
        [pn.first.number, pn.first.title] + r
      end
    end

    # parse_numbers retourne l'ensemble des comptes que l'on prend en compte
    # quand on en cumule plusieurs
    # si num est un simple numéro, renvoie le compte correspondant
    # si num se termine par % fait une recherche de type like
    # si num commence par - enlève le signe pour faire sa recherche
    def parse_numbers(num)
      case  num
      when  /\d*%$/ then @period.accounts.where('number LIKE ?', num)
      when /^-(\d*)/ then @period.accounts.find_all_by_number($1)
      else
         @period.accounts.find_all_by_number(num)
      end
    end
  end

  
end
