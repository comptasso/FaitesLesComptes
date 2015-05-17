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
  class StatsNatures

    include Utilities::ToCsv
    
    attr_reader :period

    def initialize(period, dest_ids = [0])
      @period = period
      @dest_ids =  dest_ids 
    end

    # retourne la ligne de titre 
    def title
      t = ['Natures']
      t += @period.list_months.to_abbr_with_year 
      t << 'Total' 
    end

    # retourne les lignes du tableau de stats
    def lines
      @stats ||= Nature.statistics(@period, @dest_ids)
    end

    
    # fait les totaux de toutes les lignes et renvoie un array 
    # Totaux float, float, ..., float, total des floats. Est utile pour 
    # l'affichage dans la vue et pour les export csv et pdf.
    def totals
      t=['Totaux']
      # bottoms est un arrau de totaux des différents mois de l'exercice
      bottoms = 1.upto(@period.list_months.size).collect do |i| # i va de 1 à 12 par ex
        lines.sum {|l| l[i]} # l[i] car l[0] est nature.name
      end
      t + bottoms + [bottoms.sum {|i| i}]
    end

    def to_csv(options = {col_sep:"\t"})
      CSV.generate(options) do |csv|
        csv << title          # ligne de titre
        lines.each do |line|
          csv << prepare_line(line)
        end
        csv << prepare_line(totals) # ligne de total
      end
    end

    def to_pdf
      Editions::Stats.new(@period, self)
    end
   

    protected

    # le nom de la nature suivi des autres valeurs reformatées
    def prepare_line(line)
      [line[0]] + 1.upto(line.size).collect {|i| reformat(line[i])}
    end

    # remplace les points décimaux par des virgules pour s'adapter au paramétrage
    # des tableurs français
    def reformat(number)
      return number if number.is_a? String
      sprintf('%0.02f',number).gsub('.', ',') if number
    end

    
  end
end