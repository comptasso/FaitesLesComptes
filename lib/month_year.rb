# coding: utf-8


require 'date'

#lib/month_year.rb
#
# MonthYear permet de gérer les aspects mois et année du logiciel
# Il s'agit d'une petite classe dans lib qui simplifie l'utilisation des appels 
# de pages sur la base de mois
# 
# L'initialisation est faite avec un hash comprenant les clés :month et :year
# Ces clés peuvent être sous forme numérique ou string
# 
# Une méthode de classe from_date permet également de construire un MonthYear 
# à partir d'une date MonthYear.from_date(Date.today) par exemple.
# 
# MonthYear est Comparable ce qui permet de les ordonner (utile
# pour les exercices décalés)
# MonthYear est notamment utilisé par ListMonths qui est une classe Enumerable
# d'appui à Period. Cela permet de faire Period.list_months.each et de disposer
# des MonthYear de l'exercice.
#
class MonthYear
  include Comparable

  attr_reader :year, :month

  def initialize(h)
    @date = Date.civil(h[:year].to_i, h[:month].to_i)  # pour généréer InvalidDate si les arguments sont non valables
    @month = '%02d' % @date.month
    @year = '%04d' % @date.year
  end

  # méthode de classe permettant de créer unn MonthYear à partir d'une date
  def self.from_date(date)
    MonthYear.new(year:date.year, month:date.month)
  end
  
  # calcule la distance en mois entre deux month_year
  def -(my)
     difference = 0
    if year.to_i != my.year.to_i
        difference += 12 * (year.to_i - my.year.to_i)
    end
    difference + month.to_i - my.month.to_i
  end

  
  def <=>(other)
    comparable_string <=> other.comparable_string
  end
  
  # permet de définir un range de MonthYear
  def succ
    MonthYear.new(succ_params)  
  end


  # format par défaut mm-yyyy
  def to_s
    [month, year].join('-')
  end

  # permet de définir le format de sortie sous la forme habituelle pour les dates
  # %b, %B, %y, %Y etc... avec recours à l'internationalisation.
  # Cela part de la date interne à la classe qui est le premier jour du mois
  # On peut donc avoir un format avec le jour qui sera le 1
  # to_s correspond au format mm-yyyy
  # to_short correspond au format %b (jan. fév. ...
  def to_format(format)
    I18n.l(@date, :format=>format)
  end

  # to_format avec %b donc jan.fév. mar. avr. mai,...
  def to_short
    to_format('%b')
  end

  
  
  # donne la date du début du mois
  def beginning_of_month
    @date.beginning_of_month
  end

  # donne la date de fin de mois
  def end_of_month
    @date.end_of_month
  end
  
  # pour générer une date en indiquant le jour du mois.
  #
  # Gère les mois de différentes longueurs en indiquant le dernier jour du mois
  # si le mois n'a pas assez de jours
  def to_date(day)
    d = @date.beginning_of_month + day.abs - 1
    [@date.end_of_month, d].min
  end

  # retourne un hash qui est utilisé dans la constuction des url
  def to_french_h
    {an:@year, mois:@month}
  end

  # crée un hash à corresondant au même mois de l'année précédente
  def previous_year
    MonthYear.from_date(@date.years_ago(1))
  end
  
  # crée un hash correspondant au mois précédent
  def previous_month
    MonthYear.from_date(@date << 1)
  end

  

  # trouve la date la plus adaptée. Date du jour si Date.today est dans le mois,
  # sinon début du mois si Date.today est ancien
  # ou fin de mois si Date.today est futur
  def guess_date
    d = Date.today
    return d if include? d
    return end_of_month if younger_than? d
    return beginning_of_month if older_than? d
  end

  protected

  # construit la chaine yyyymm pour faire les comparaisons
  def comparable_string
    (@year+@month).to_i
  end

  # indique si une date est comprise dans le mois défini par MonthYear
  def include?(date)
    date.in?(beginning_of_month..end_of_month)
  end

  # indique si la month_year est antérieur à  la date donnée
  def older_than?(date)
    beginning_of_month > date
  end

  # indique si le month_year est future par rapport à la date donnée
  def younger_than?(date)
    end_of_month < date
  end
  
  # définit les paramètres permettant de créer le MonthYear suivant 
  def succ_params
    mois = month.succ
    an = year
    if mois.to_i > 12
      mois = '01'
      an = year.succ
    end
    {year:an.to_s, month:mois.to_s}
    
  end

 

end
