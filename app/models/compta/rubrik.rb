module Compta
  class Rubrik
      
    
    attr_reader :period, :rubrik, :brut, :amortissement
    
    delegate :depth, :title, to: :rubrik
    
    def initialize(rubrik, period)
      @period = period
      @rubrik = rubrik 
      # TODO voir éventuellement à mettre ici une alerte si le period 
      # n'est pas celui déja calculé. 
      # TODO Où se passer peut-être complètement de Compta::Rubrik qui 
      # avait du sens pour prendre en compte l'exercice.
      
    end
    
    def brut(period = nil)
      rubrik.brut # ||= lines.sum(&:brut)
    end
    
    def amortissement(period = nil)
      rubrik.amortissement #||= lines.sum(&:amortissement)
    end
    
    def net(period=nil)
      brut - amortissement
    end
    
    def previous_net(period=nil)
      rubrik.previous_net 
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
#    def lines
#      @lines ||= set_lines
#    end
#    
#    def set_lines
#      if rubrik.leaf? 
#        return all_lines
#      else
#        return rubrik.children.collect {|ch| ch.to_compta_rubrik(period)}
#      end
#    end
#    
#    def all_lines
#      @all_lines ||= Compta::RubrikParser.new(period, rubrik.folio.sens, rubrik.numeros).rubrik_lines
#    end
    
    
  end
end
