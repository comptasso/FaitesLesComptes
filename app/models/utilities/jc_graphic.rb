# coding: utf-8


# ce module permet d'inclure dans un modèle les méthodes nécessaires à la construction d'un
# graphique tel que défini par Utilities::Graphic
# la classe dans laquelle on inclut ce module doit avoir une méthode monthly_value(months)
# qui retourne le tableau des données mensuelles recherchées
module Utilities::JcGraphic
  attr_reader :graphic

  # permet de retourner ou de créer la variable d'instance
  def graphic(period)
    @graphic ||= default_graphic(period)
  end

  # construit un graphique des données mensuelles du livre par défaut avec deux exercices
  def default_graphic(period)
    if period.previous_period?
      @graphic = two_years_monthly_graphic(period)
    else
      @graphic= one_year_monthly_graphic(period)
    end
  end


  # construit un tableau pour l'axe des abscisse : du genre jan,fév, mar,...
  def ticks(period)
    period.list_months('%b')
  end


  # la construction d'un graphique sur un an
  def one_year_monthly_graphic(period)
    mg= Utilities::Graphic.new(self.ticks(period))
    mg.add_serie(:legend=>period.exercice, :datas=>self.monthly_datas_for_chart(period.list_months('%m-%Y')), :period_id=>period.id )
    mg
  end

  # construction d'un graphique sur deux ans
  def two_years_monthly_graphic(period, &block)
    mg= Utilities::Graphic.new(self.ticks(period))
    months= period.list_months('%m-%Y') # les mois du dernier exercice servent de référence
    pp=period.previous_period
    mg.add_serie(:legend=>pp.exercice, :datas=>previous_year_monthly_datas_for_chart(months), :period_id=>pp.id )
    mg.add_serie(:legend=>period.exercice, :datas=>self.monthly_datas_for_chart(months), :period_id=>period.id )
    mg
  end

   # calcule le total des lignes pour chacun des mois de l'exercice transmis en paramètres
  # renvoie un array donnant le total credit - debit des lignes des mois
  # En pratique, on appelle les deux méthodes avec la même variable months
  # pour avoir des séries de même longueur même lorsque les éxercices sont de longueur différentes.
  # month doit être au format mm-yyyy (ou mmyyyy ou mm/yyyy)
  #
  def monthly_datas_for_chart(months)
    months.map {|m| monthly_value(m)}
  end

  def previous_year_monthly_datas_for_chart(months)
    months.map  do |m|
      month= m[/^\d{2}/]; year = m[/\d{4}$/].to_i - 1
        monthly_value("#{month}-#{year}")
    end
  end
end
