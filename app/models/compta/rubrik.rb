module Compta
  class Rubrik
    
    
    
    attr_reader :period, :rubrik, :brut, :amortissement
    
    delegate :depth, :title, to: :rubrik
    
    def initialize(rubrik, period)
      @period = period
      @rubrik = rubrik      
    end
    
    def brut(period = nil)
      @brut ||= lines.sum(&:brut)
    end
    
    def amortissement(period = nil)
      @amortissement ||= lines.sum(&:amortissement)
    end
    
    def net(period=nil)
      brut - amortissement
    end
    
    def previous_net(period=nil)
      lines.sum { |l| l.previous_net(period) }
    end
    
      # retourne la ligne de total de la rubrique
    def totals(period = nil)
      [rubrik.name, brut, amortissement, net, previous_net] rescue ['ERREUR', 0.0, 0.0, 0.0, 0.0]
    end
    
    alias total_actif totals

    def total_passif(period=nil)
      [rubrik.name, net, previous_net] rescue ['ERREUR', 0.0, 0,0]
     end
    
    protected
    
    
    def lines
      @lines ||= set_lines
    end
    
    # construit les lignes qui sont soit des lignes liées à des comptes
    # si la rubrik est une feuille de l'arborescence, 
    # soit une collection de sous rubriks.
    def set_lines
      if rubrik.leaf? 
        return all_lines
      else
        return rubrik.children.collect {|ch| ch.to_compta_rubrik(period)}
      end
    end
    
    # Récupère toutes les lignes dépendant d'une rubrik feuille de l'arborescence
    def all_lines
      @all_lines ||= Compta::RubrikParser.new(period, rubrik.folio.sens, rubrik.numeros).rubrik_lines
    end
    
    
  end
end
