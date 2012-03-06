# coding: utf-8


# ce module permet d'inclure dans un modèle les méthodes nécessaires à la construction d'un
# graphique tel que défini par Utilities::Graphic
# La méthode pour calculer le solde est :
# - soit monthly_value(mm-yyyy)
# - soit une méthode fournie en deuxième argument qui accepte ce format (mm-yyyy)
module Utilities::JcGraphic
  attr_reader :graphic

  # permet de retourner ou de créer la variable d'instance
  # ce qui fait une sorte de cache puisque graphic est ensuite appelé à plusieurs
  # reprises pour founir ses différentes éléments
  def graphic(period, meth=nil)
    @chart_value_method = meth
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
  def two_years_monthly_graphic(period)
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
    months.map do |m|
      raise ArgumentError unless m=~ /^\d{2}/ && m=~ /\d{4}$/
      if @chart_value_method
        self.send(@chart_value_method,m)
      else
        monthly_value(m)
      end
    end
  end

  # construit la liste des mois de l'année précédente
  # puis appelle monthly_datas_for_chart
  def previous_year_monthly_datas_for_chart(months)
    previous_year_months = months.map   { |m| month= m[/^\d{2}/]; year = m[/\d{4}$/].to_i - 1; "#{month}-#{year}" }
    monthly_datas_for_chart(previous_year_months)
  end

  
end
