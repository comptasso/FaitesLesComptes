# coding: utf-8

# Cette classe permet de représenter un graphique
# elle est appelée par un objet (Book par exemple) qui doit construire le graphique
# en fournissant les marques de l'axe des x (ticks)
# puis en ajoutant (add_serie) des séries sous forme de hash avec légend et datas
# Des erreurs sont levées s'il manque la légende, ou si le nombre de datas est différents de ticks
#
# Chaque série ajoutée est un hash dormé de :legend et :datas. Une information additionnelle
# peut être fournie avec la clé :period_id. Cette information permet de cliquer sur
# un élément du graphe et d'aboutir à la page correspondante (essentiel lorsque le graphe
# comprend plusieurs exercices)
#
  class  Utilities::Graphic

    attr_reader :ticks, :series, :legend, :period_ids, :month_years

    # initialisation avec l'axe des x sous forme d'array.
    # le contenu de l'array sera les étiquettes de l'axe des abscisses
    def initialize(ticks)
      raise 'Ticks should be an array with at least one element' unless ticks.is_a?(Array) && !ticks.empty?
       @ticks=ticks
       @series=[]  
       @legend=[]
       @period_ids=[]
       @month_years=[]
    end


    def add_serie(serie)
      check_serie(serie)
      @series << serie[:datas]
      @legend << serie[:legend]
      @period_ids << serie[:period_id]
      @month_years << serie[:month_years]
      true
    end

    def nb_series
      @series.size
    end

    
    # surcharge de l'opérateur égalité
    def ==(graph)

    return false if self.legend != graph.legend
    return false if self.nb_series != graph.nb_series
    self.series.each_with_index do |s,i|
      return false if s != graph.series[i]
    end
    return false if self.period_ids != graph.period_ids
    return true

  end


    protected

    # vérifie que les infos indispensables sont là
    # et que la taille de la série est cohérente avec les ticks
    def check_serie(serie)
      raise 'Missing datas for this serie' if serie[:datas].nil?
      raise 'Missing legend for this serie' if serie[:legend].nil?
      raise 'Number of datas and ticks are different' if (serie[:datas].size != @ticks.size)
    end

  end

