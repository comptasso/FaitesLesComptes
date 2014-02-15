# coding: utf-8


# ce module permet d'inclure dans un modèle les méthodes nécessaires à la construction d'un
# graphique tel que défini par Utilities::Graphic
module Utilities::JcGraphic

  # permet de retourner ou de créer la variable d'instance
  # ce qui fait un cache puisque graphic est ensuite appelé à plusieurs
  # reprises pour founir ses différentes éléments
  def graphic(period)
    @graphic ||= default_graphic(period) 
  end


protected

  # construit un graphique des données mensuelles du livre par défaut avec deux exercices
  def default_graphic(period)
    @graphic = Utilities::Graphic.new(self, period, :bar)
  end

  
  

  
end
