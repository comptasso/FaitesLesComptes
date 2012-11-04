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
  #  '20%' veut dire le compte 20 et tous ceux qui commencent par 20
  #  '-280' signifie que le solde sera à prendre dans la seconde colonne (amortissements ou provisions)
  #  
  #
  class Rubrik

    attr_accessor :title

    def initialize(period, title, sens, numeros)
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
      @lines ||= @numeros.collect{|n| account_values(n) }.compact
    end

    # retourne la ligne de total de la rubrique
    def totals
      [@title, brut, amortissement, net]
    end

    def detailed_list
      lines.collect {|l| [l[0], l[1], l[2] -  l[3]]}
    end

    def complete_list
      [ @title] + detailed_list + ["Total #{@title}", brut - amortissement]
    end



    def brut
      @brut ||= lines.sum {|v| v[2]}
    end

    def amortissement
      @amortissement ||= lines.sum {|v| v[3]}
    end

    alias depreciation amortissement

    def net
      @net ||= (brut - amortissement) rescue 0.0
    end

    def previous_net
      return 0 unless @period.previous_period?
      Compta::Rubrik.new(@period.previous_period, @title, @sens, @numeros).net
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

        # prise en compte du sens
        if @sens == :actif
          r.collect! {|v| -v }
        end
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
      when  /^-(\d*)%$/ then @period.accounts.where('number LIKE ?', $1)
      when /^-(\d*)/ then @period.accounts.find_all_by_number($1)
      else
         @period.accounts.find_all_by_number(num)
      end
    end
  end

  
end
