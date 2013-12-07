module Compta
  class Rubrik
    
    attr_reader :period, :rubrik, :brut, :amortissement
    
    delegate :depth, to: :rubrik
    
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
    
    # lines renvoie les rubrik_lines qui construisent la rubrique
    # lines est en fait identique à la méthode protected all_lines
    # sauf pour la Rubrik résultat (le compte 12).
    #
    # Le but est d'avoir une seule ligne pour cette Rubrik résultat alors
    # que ses valeurs sont calculées à partir du compte 12 mais aussi de tout
    # les comptes 6 et 7.
    #
    def lines
      @lines ||= set_lines
    end
    
    def set_lines
      if rubrik.leaf? 
        if rubrik.resultat?
          return [Compta::RubrikResult.new(period, :passif, '12')]
        else
          return all_lines
        end
      else
        return rubrik.children.collect {|ch| ch.to_compta_rubrik(period)}
      end
    end
    
    
    def all_lines
      @all_lines ||= Compta::RubrikParser.new(period, rubrik.folio.sens, rubrik.numeros).rubrik_lines
    end
    
    
  end
end
