# Classe destinée à remplacer les actuels Compta::Rubriks et Compta::Rubrik
# pour permettre de manipuler les nomenclatures qui servent à établir les documents
# comptables (Actif, Passif, ...)
# 
# ActsAsTree
#
class Rubrik < ActiveRecord::Base
  include ActsAsTree

  belongs_to :folio
  attr_accessible :name, :numeros, :parent_id, :position
  attr_reader 
  acts_as_tree :order => "position"
  
  
  
  
  
  # indique si la rubrique est le résultat de l'exercice (le compte 12).
    # ceci pour ne pas afficher le détail de tous les comptes 6 et 7
    # lorsque l'on affiche le détail du passif
    def resultat?
      return false unless leaf? # ce n'est possible que pour une rubrique qui est au bout d'une branche
      '12'.in?(numeros.split) # split est essentiel sinon il répond true pour des numéros comme 212
    end
    
     # lines renvoie les rubrik_lines qui construisent la rubrique
    # lines est en fait identique à la méthode protected all_lines
    # sauf pour la Rubrik résultat (le compte 12).
    #
    # Le but est d'avoir une seule ligne pour cette Rubrik résultat alors
    # que ses valeurs sont calculées à partir du compte 12 mais aussi de tout
    # les comptes 6 et 7.
    #
    def lines(period)
      if leaf? 
        if resultat?
          return [Compta::RubrikResult.new(period, :passif, '12')]
        else
          return all_lines(period)
        end
      else
        return children
      end
    end
    
    # détermine le niveau dans l'arbre
    # level = 0 pour root
    def level
      niveau = 0
      r = self
      while !r.root?
        r = r.parent; niveau += 1
      end
      niveau
    end
    
    
      # retourne la ligne de total de la rubrique
    def totals(period)
      [name, brut(period), amortissement(period), net(period), previous_net(period)] rescue ['ERREUR', 0.0, 0.0, 0.0, 0.0]
    end

    alias total_actif totals

    def total_passif(period)
      [name, net(period), previous_net(period)]
    end

    # crée un array avec le titre suivi de l'ensemble des lignes suivi de la ligne de total
    def complete_list(period)
      [name] + all_lines(period) + totals(period) if leaf?
    end


    def brut(period)
      lines(period).sum { |l| (l.class == Compta::RubrikLine) ? l.brut : l.brut(period) }
    end

    def amortissement(period)
      lines(period).sum { |l| (l.class == Compta::RubrikLine) ? l.amortissement : l.amortissement(period) }
    end

    alias depreciation amortissement

    def net(period)
      (brut(period) - amortissement(period)) rescue 0.0
    end

    def previous_net(period)
      lines(period).sum { |l| (l.class == Compta::RubrikLine) ? l.previous_net : l.previous_net(period) }
    end

    # la profondeur (depth) d'une rubrique est 0
    # cette méthode existe pour pouvoir définir la profondeur
    # des Compta::Rubriks
    # TODO avoir un calcul plus général puisqu'on a plus qu'une rubrik et non 
    # des compta::rubriks et compta::rubrik
    def depth
      0
    end

    
    protected

    # pour chacun des comptes construit un tableau
    # avec le numéro de compte, l'intitulé, le solde dans le sens demandé
    # ou l'inverse du solde si le sens est contraire
    # Une particularité est le compte 12 (résultat) qui dans la nomencalture
    # est indiqué comme '12, 7, -6' et pour lequel lines, ne doit renvoyer
    # qu'un compte 12
    #
    def all_lines(period)
        @all_lines ||= Compta::RubrikParser.new(period, folio.sens, numeros).rubrik_lines
    end
    

end
