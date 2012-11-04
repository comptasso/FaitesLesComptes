# coding: utf-8

module Compta

  # Rubriks est une classe comportant un titre et une collection répondant aux
  # méthodes brut, amortissement, net et previous net
  # ainsi que totals qui fournit alors une ligne avec les différentes valeurs voulues
  #
  # la méthode lines permet d'afficher les différentes lignes de la collection
  #
  class Rubriks
    def initialize(period, title, collection)
      @period = period
      @collection = collection
      @title = title
    end

    # la ligne de total avec son titre et ses 3 valeurs
    def totals
      [@title, brut, amortissement, net]
    end

    # le montant brut total de la collection
    def brut
      @collection.sum(&:brut)
    end

    # le montant des amortissements ou dépreciation
    def amortissement
      @collection.sum(&:amortissement)
    end

    alias depreciation amortissement

    # le montant net de la collection
    def net
      @collection.sum(&:net)
    end

    # retourne un array des différents éléments de la collection avec leurs totaux
    def lines
      @collection.collect {|r| r.totals}
    end

#    def detailed_list
#      @collection.map {|c| c.detailed_list}
#    end

  end
end
