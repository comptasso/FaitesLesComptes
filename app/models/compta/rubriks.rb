# coding: utf-8

module Compta

  # Rubriks est une classe comportant un titre et une collection répondant aux
  # méthodes brut, amortissement, net et previous net
  # ainsi que totals qui forunit alors une ligne avec les différentes valeurs voulues
  #
  # la méthode lines permet d'afficher les différentes lignes
  #
  class Rubriks
    def initialize(period, title, collection)
      @period = period
      @collection = collection
      @title = title
    end

    def totals
      [@title, brut, amortissement, net]
    end

    def brut
      @collection.sum(&:brut)
    end

    def amortissement
      @collection.sum(&:amortissement)
    end

    def net
      @collection.sum(&:net)
    end

    def lines
      @collection.collect {|r| r.totals}
    end

  end
end
