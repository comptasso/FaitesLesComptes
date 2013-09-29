# Classe destinée à remplacer les actuels Compta::Rubriks et Compta::Rubrik
# pour permettre de manipuler les nomenclatures qui servent à établir les documents
# comptables (Actif, Passif, ...)
# 
# ActsAsTree
#
class Rubrik < ActiveRecord::Base
  include ActsAsTree

  belongs_to :folio
  attr_accessible :name, :numeros, :parent_id
  acts_as_tree :order => "name"
  
  # indique si la rubrique est le résultat de l'exercice (le compte 12).
    # ceci pour ne pas afficher le détail de tous les comptes 6 et 7
    # lorsque l'on affiche le détail du passif
    def resultat?
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
      if resultat?
        [Compta::RubrikResult.new(period, :passif, '12')]
      else
        all_lines
      end
    end
    
      # retourne la ligne de total de la rubrique
    def totals
      [name, brut, amortissement, net, previous_net] rescue ['ERREUR', 0.0, 0.0, 0.0, 0.0]
    end

#    def totals_prefix(prefix = 'Total ')
#      v = totals
#      v[0] = prefix + v[0].to_s
#      v
#    end

    alias total_actif totals

    def total_passif
      [name, net, previous_net]
    end

    # crée un array avec le titre suivi de l'ensemble des lignes suivi de la ligne de total
    def complete_list
      [name] + all_lines + totals
    end


    def brut
      @brut ||= all_lines.sum(&:brut)
    end

    def amortissement
      @amortissement ||= all_lines.sum(&:amortissement)
    end

    alias depreciation amortissement

    def net
      @net ||= (brut - amortissement) rescue 0.0
    end

    def previous_net
      @previous_net ||= all_lines.sum(&:previous_net)
    end

    # la profondeur (depth) d'une rubrique est 0
    # cette méthode existe pour pouvoir définir la profondeur
    # des Compta::Rubriks
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
