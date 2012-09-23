# coding: utf-8


# ce module permet d'inclure dans un modèle les méthodes nécessaires à la construction d'un
# graphique tel que défini par Utilities::Graphic
# La méthode pour calculer le solde est :
# - soit par défaut monthly_value(date)
# - soit une méthode fournie par la varaible d'instance @chart_value_method
# typiquement la variable d'instance est fixée à l'initialisation par un after_initialize
module Utilities::JcGraphic

  # permet de retourner ou de créer la variable d'instance
  # ce qui fait un cache puisque graphic est ensuite appelé à plusieurs
  # reprises pour founir ses différentes éléments
  def graphic(period)
    @graphic ||= default_graphic(period)
  end


  # renvoie le type de graphique et le nom de la class
  def pave_char
    ['book_pave', self.class.name.underscore]
  end


  # construit un graphique des données mensuelles du livre par défaut avec deux exercices
  def default_graphic(period)
    if period.previous_period?
      @graphic = two_years_monthly_graphic(period)
    else
      @graphic = one_year_monthly_graphic(period)
    end
  end


  # construit un tableau pour l'axe des abscisse : du genre jan,fév, mar,...
  def ticks(period)
    period.list_months.to_abbr
  end


  # la construction d'un graphique sur un an
  def one_year_monthly_graphic(period)
    mg= Utilities::Graphic.new(self.ticks(period))
    mg.add_serie(:legend=>period.exercice, :datas=>self.monthly_datas_for_chart(period.list_months), :period_id=>period.id, :month_years=>period.list_months.to_list('%m-%Y' ))
    mg
  end

  # construction d'un graphique sur deux ans; Les mois du dernier exercice servent de
  # référence car il est plus fréquent que le premier exercice soit plus court que les autres
  # mais la chose est rare en sens inverse.
  def two_years_monthly_graphic(period)
    mg= Utilities::Graphic.new(self.ticks(period))
    months= period.list_months # les mois du dernier exercice servent de référence
    pp=period.previous_period
    mg.add_serie(:legend=>pp.exercice, :datas=>previous_year_monthly_datas_for_chart(months), :period_id=>pp.id, :month_years=>month_year_values(months, true))
    mg.add_serie(:legend=>period.exercice, :datas=>self.monthly_datas_for_chart(months), :period_id=>period.id, :month_years=>month_year_values(months))
    mg
  end

  # calcule le total des lignes pour chacun des mois de l'exercice transmis en paramètres
  # renvoie un array donnant le total credit - debit des lignes des mois
  # En pratique, on appelle les deux méthodes avec la même variable months
  # pour avoir des séries de même longueur même lorsque les éxercices sont de longueur différentes.
  # month doit être au format mm-yyyy (ou mmyyyy ou mm/yyyy)
  #
  def monthly_datas_for_chart(months)
    meth = @chart_value_method ? @chart_value_method : :monthly_value
    months.map {|m| self.send(meth, m.end_of_month) }
  end

  # construit la liste des mois de l'année précédente
  # puis appelle monthly_datas_for_chart
  def previous_year_monthly_datas_for_chart(months)
    previous_year_months = months.map   { |m| MonthYear.from_date(m.end_of_month.years_ago(1)) }
    monthly_datas_for_chart(previous_year_months)
  end


  # utilise une collection de date pour renvoyer un array sous la forme mm-yyyy
  # le booleen previous permet de se mettre un an plus tôt
  def month_year_values(months, previous_period = false)
    months.map {|m| MonthYear.from_date(previous_period ? m.end_of_month.years_ago(1) : m.end_of_month).to_s}
  end

  
end
