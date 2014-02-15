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

  attr_reader :ticks, :series, :legend, :period_ids, :month_years, :type

  # initialisation à partir d'un objet (un book, un virtual_book ou un sector)
  # 
  # book appelle  a priori un graphe en barre pour afficher les recettes ou les dépenses
  # sector donne un graphe en barre pour les résultats de chaque mois
  # virtual_book représente caisse et banques et affichent un graphe en ligne.
  # 
  # C'est la classe appelante qui demande son type de graphe et l'exercice voulu, 
  # son type (:bar ou :line) 
  # 
  def initialize(obj, period, type)
    @period = period
    @type = type
    @obj = obj 
       
    @previous_period = period.previous_period? ? period.previous_period : nil
       
    @month_years = []
    @period_ids = []
    @series=[]  
    @legend=[]
    build_series
  end
    
  # les ticks sont les légendes de l'axe des x : concrètement c'est un 
  # array qui est 'jan, fév, mar, avr... pour un exercice correspondant à l'année civile
  def ticks
    @period.list_months.to_abbr
  end
    
    
  # build_series va ajouter une ou deux séries selon qu'il y a un exercice précédent
  def build_series
    add_serie(@previous_period) if @previous_period
    add_serie(@period)
  end
    
    

  # ajoute les éléments constitutifs d'une série au graphique
  #
  # la légende, l'id de l'exercice, les month_years qui sont au format mm-yyyy
  # attention, il ne doit pas y avoir de trou
  # et les données (là aussi, il ne doit pas y avoir de trou)
  def add_serie(exercice)
    @legend << exercice.short_exercice
    @period_ids << exercice.id
    @month_years <<  build_month_years(exercice)
    @series << build_datas(@obj, exercice)
  end

  def nb_series
    @series.size
  end
    
  # Les month_years sont du texte au format mm-yyyy
  # C'est la longueur du dernier exercice qui détermine le nombre de 
  # month_years 
  # 
  def build_month_years(exercice) 
    if exercice == @period
      return @period.list_months.to_list('%m-%Y' )
    else # on a demandé l'exercice précédent
      nbm = @period.nb_months
      ListMonths.new(@period.start_date << nbm, @period.close_date << nbm ).to_list('%m-%Y')
    end
  end
    
  # interroge obj pour lui demander ses données pour l'exercice en deuxième argument
  def build_datas(obj, exercice)
    h = obj.query_monthly_datas(exercice)
    h.default = '0' # car la requete ne renvoie pas les mois où il n'y a pas d'écriture
    res = build_month_years(exercice).collect {|my| h[my] }
    res = accumulate_values(res, exercice) if @type == :line
    res
  end
    
   

  protected

  # prend l'ensemble des valeurs et en fait une somme accumulée. 
  # Utile pour les graphiques de type line.
  # 
  # La valeur de départ (acc) est égale à la dernière valeur de la série 
  # précédente si l'exerice précédent est ouvert (car sinon les reports sont
  # déjà faits et il n'y a pas lieu de reporter la valeur). 
  #   
  #
  def accumulate_values(res, exercice)
    acc = 0.0
    if exercice.previous_period? && exercice.previous_period.open
      acc = @series.last.last.to_f 
    end
    res.collect { |val| acc += val.to_f; acc.to_s }
  end

end

