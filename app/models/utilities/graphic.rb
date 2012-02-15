

# coding: utf-8

# Cette classe permet de représenter un graphique
# elle est appelée par un objet (Book par exemple) qui doit construire le graphique
# en fournissant les marques de l'axe des x (ticks)
# puis en ajoutant (add_serie) des séries sous forme de hash avec légend et datas
# Des erreurs sont levées s'il manque la légende, ou si le nombre de datas est différents de ticks
#
  class  Utilities::Graphic

    attr_reader :ticks, :series, :legend

    def initialize(ticks)
      raise 'Ticks should be an array with at least one element' unless ticks.is_a?(Array) && !ticks.empty?
       @ticks=ticks
       @series=[]
       @legend=[]
    end

    def add_serie(serie)
      check_serie(serie)
      @series << serie[:datas]
      @legend << serie[:legend]
      true
    end

    def nb_series
      @series.size
    end

    def ==(graph)
    return false if self.legend != graph.legend
    return false if self.nb_series != graph.nb_series
    self.series.each_with_index do |s,i|
      return false if s != graph.series[i]
    end
    return true

  end


    protected

    def check_serie(serie)
      raise 'Missing datas for this serie' if serie[:datas].nil?
      raise 'Missing legend for this serie' if serie[:legend].nil?
      raise 'Number of datas and ticks are different' if (serie[:datas].size != @ticks.size)
    end

  end

