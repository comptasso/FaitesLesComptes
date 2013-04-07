# coding: utf-8

require 'month_year'

# Classe représentant une liste de Mois
#
# Cette classe est énumérable et est constituée d'une collection de MonthYear
class ListMonths
  include Enumerable

  def initialize(begin_date, end_date)
    @lm = []
    while begin_date < end_date
    @lm << MonthYear.from_date(begin_date)
    begin_date =  begin_date >> 1 # passe au mois suivant
    end
  end

  def to_s
    collect {|m| m.to_s}.join(', ')
  end

  # fournit une abbréviation du type jan. ou fév.
  def to_abbr
    to_list('%b')
  end

  # renvoie un intitulé de type jan. 13 ou sept. 13
  def to_abbr_with_year
    to_list('%b %y')
  end
  
  # renvoie un tableau des mois au format demandé
  #
  # utilisé par to_abbr ou to_abbr_with_year
  def to_list(format = nil)
    collect {|m| m.to_format(format) }
  end


  def each
    @lm.sort.each {|i| yield i}
  end

  def size
    @lm.size
  end

  alias length size

end
