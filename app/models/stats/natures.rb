# coding: utf-8

module Stats

  # la classe construit un tableau de statistiques sur les débits et crédits
  # de chaque nature d'un exercice et par mois à partir de la méthode de classe
  # #statistics de Nature.
  # 
  # Les arguments de new sont l'exercice et un array facultatif des ids des 
  # destinations. La valeur [0] par défaut indique que l'on ne veut pas filtrer
  # sur les destinations.
  # 
  # La méthode #title renvoie la ligne de titre, généralement
  # de 14 colonnes : Natures, suivi des mois, Total
  # 
  # La méthode #lines renvoie une Array avec pour ligne, 
  # le nom de la nature, les totaux par mois et le total de l'exercice
  # 
  # La méthode #totals renvoie la ligne de totaux de ce tableau
  # 
  # Les méthode #to_csv et #to_pdf permettent l'export
  # 
  class Natures < Statistics 

    
    # retourne la ligne de titre 
    def title
      t = ['Natures']
      t += @period.list_months.to_abbr_with_year 
      t << 'Total' 
    end

    # retourne les lignes du tableau de stats
    def lines
      @stats ||= Nature.statistics(@period, @list_ids)
    end

    
    
    def to_pdf
      Editions::Stats.new(@period, self)
    end
   

    
    
  end
end