# coding: utf-8

module Stats

  # La classe Page est destinée à peremttre l'édition de statistiques sur
  # plusieurs pages.
  #
  # La première colonne est un String (libellé), les autres colonnes sont des valeurs
  # qui peuvent être sommées
  # Ce modèle page est utilisé pour les statistiques par nature qui sont généra-
  # lement sur 12 mois (libellé de la nature puis 12 valeurs puis le total de
  # ces 12 valeurs
  #
  # La page calcule sa ligne de total de la page et son à reporter
  #
  class Page
    include Comparable

    attr_reader :number, :title, :nb_cols
    attr_writer :report_values
    
    def initialize(number, title_line, stat_lines)
      @number = number
      @lines = stat_lines
      @title = title_line
      @nb_cols = @title.size 
    end

     # fait les totaux de toutes les lignes et renvoie un array
    # Totaux float, float, ..., float, total des floats
    def total_page_line
      ['Total page'] + total_page_values.collect {|v| reformat v}
    end

    def report_line
      return nil if @number == 1 || @report_values == nil
      ['Reports'] + @report_values.collect {|v| reformat v}
    end

    # fait la somme de total_page et de to_report
    def to_report_line
      t = (is_last? ? (['Total général']) : (['A reporter']))
      t + to_report_values.collect {|v| reformat v}
    end

    def formatted_lines
      @lines.collect do |l|
        l.collect {|v| reformat v}
      end
    end



    def is_last?
      @last ||= false
    end

    def is_last(b = true)
      @last = b
    end

    # renvoie les valeurs à reporter
    # cette méthode est publique pour que la page suivante puisse y accéder
    def to_report_values
      rv = report_values # pour être sur que la variable d'instance ait des valeurs
      tpv = total_page_values # pour éviter 12 calculs des sommes
      0.upto(@nb_cols-2).collect {|i| rv[i] + tpv[i]}
    end

    protected

    # renvoie @report ou des 0 si @report n'a pas été défini pour cette page
    def report_values
      @report_values ||=  1.upto(@nb_cols-1).collect {|i| 0} 
    end

    # calcule le total des valeurs (donc pas la première colonne)
    def total_page_values
      1.upto(@nb_cols-1).collect do |i| # i va de 1 à 12 par ex
        @lines.sum {|l| l[i]} # l[i] car la première colonne l[0] ne se totalise pas
      end
    end

    def <=>(other)
      number <=> other.number
    end

     def reformat(val)
   return val if val.is_a? String
   sprintf('%0.02f',val).gsub('.', ',') if val
  end

  end
end