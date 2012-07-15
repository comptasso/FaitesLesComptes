# coding: utf-8

module Stats

  # la classe construit un tableau de statistiques sur les débits et crédits
  # de chaque nature d'un exercice et par mois.
  # La classe se construit donc à partir d'un exercice et est capable de
  # restituer tous les éléments nécessaires à l'affichage des statistiques.
  # Un deuxième argument optionnel est l'id d'une destination pour filter les résultats
  # sur une destination
  # La ligne de titre, généralement de 14 colonnes (Natures, suivi des mois,
  # puis de Total)
  # puis un array de 14 valeurs également pour chaque colonne
  # le nom de la nature, les totaux par mois et le total de l'exercice 
  # puis la ligne de total
  class StatsNatures 
    
    attr_reader :period

    def initialize(period, dest_id = 0)
      @period = period
      @dest_id = dest_id
    end

    # retourne la ligne de titre 
    def title 
      t = ['Natures']
      t += @period.list_months.to_abbr_with_year 
      t << 'Total' 
    end

    # retourne les lignes du tableau de stats
    def lines
      @stats ||= stats
    end

    def totals
      t=['Totaux']
      # bottoms est un arrau de totaux des différents mois de l'exercice
      bottoms = 1.upto(@period.list_months.size).collect do |i| # i va de 1 à 12 par ex
        lines.sum {|l| l[i]} # l[i] car l[0] est nature.name
      end
      t + bottoms + [bottoms.sum {|i| i}]
    end

    protected

    def stats
      stats = []
      @period.natures.order('income_outcome DESC', 'name ASC').each do |n|
        stats << [n.name] + n.stat_with_cumul(@dest_id)
      end
      @stats = stats
    end
    
  end
end