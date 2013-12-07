# require 'pdf_document/pdf_rubriks.rb'

# Classe destinée à produire les documents comptables tels qu'actif ou passif
# Chaque rubrique qui se lit à partir d'un folio est capable de calculer 
# ses soldes, en listant ses enfants.
# 
#  Le gem acts_as_tree donne les méthodes leaf et children.
#  
#   Un champ booleen is_leaf est ajouté dans la table permettant d'éviter les 
#   trop nombreuses interrogations de la table à chaque fois qu'on veut savoir
#   si la rubrik est une feuille ou non (ce qui est dû à la récursivité de 
#   certaines fonctions)  
# 
# Une autre logique aurait pu être de faire deux modèles différents, avec des
# rubriques et des sous rubriques. Peut être avec la logique STI
#
class Rubrik < ActiveRecord::Base
  include ActsAsTree

  belongs_to :folio
  attr_accessible :name, :numeros, :parent_id, :position
  
  acts_as_tree :order => "position"
  
  
  alias collection children
  
  # repris ces lignes de github ascts_as_tree car curieusement ne semblent pas fonctionner
  # par défaut
  # Returns list of descendants, starting from current node, not including current node.
    #
    # root.descendants # => [child1, child2, subchild1, subchild2, subchild3, subchild4]
    def descendants
      children.each_with_object(children) {|child, arr|
        arr.concat child.descendants
      }.uniq
    end

    # Returns list of descendants, starting from current node, including current node.
    #
    # root.self_and_descendants # => [root, child1, child2, subchild1, subchild2, subchild3, subchild4]
    def self_and_descendants
      [self] + descendants
    end
  
  # surcharge de la méthode leaf? du gem acts_as_tree afin d'utiliser le champ
  # is_leaf.
    def leaf?
      is_leaf 
    end
  
  
  # title est un alias de name car PdfDocument utilise title et non name
  # period = nil est nécessaire car dans PdfSimple#prepare_line certaines colonnes ont besoin
  # de period pour être calculées.
  def title(period = nil)
    name
  end
  
   
  
  
  # indique si la rubrique est le résultat de l'exercice (le compte 12).
    # ceci pour ne pas afficher le détail de tous les comptes 6 et 7
    # lorsque l'on affiche le détail du passif
    def resultat?
      return false unless leaf? # ce n'est possible que pour une rubrique qui est au bout d'une branche
      '12'.in?(numeros.split) # split est essentiel sinon il répond true pour des numéros comme 212
    end
    
    # Utilisé pour les vues de détail de Sheet,
    # permet de récupérer les Rubrik et les RubrikLine
    #
    # Fetch_lines est récursif
    #
    def fetch_lines(period)
      
      fl = []
      children.each do |c|
        c_leaf = c.leaf?   # teste une seule fois si c'est une feuille
        clps = c.lines(period) if c_leaf # récupère les lignes si c'est une feuille
        
        fl += c.fetch_lines(period) unless c_leaf # recursif si ce n'est pas une feuille
        fl += clps if c_leaf && !clps.empty? # ajoute les lignes si c'est une feuille non vide
        fl << c.to_compta_rubrik(period) if c_leaf # ajoute la feuille elle-même
      end
      fl << self.to_compta_rubrik(period) # finalise en ajoutant la rubrik appelante qui se met en total.
      fl
    end
     
    # Récupère les différentes rubriks avec les sous rubriks
    # mais ne prend pas le détail des lignes. 
    # 
    # Utilisé pour la construction des folios (PdfDocument::Sheet) lorsqu'on 
    # n'affiche pas tous les détails de comptes mais seulement les rubriques
    # 
    #
    def fetch_rubriks(period)
      result = []
      children.each do |c|
        
        if c.leaf? 
          result << c.to_compta_rubrik(period)
        else
          result += c.fetch_rubriks(period)
        end
      end
      result << self.to_compta_rubrik(period)
    end
    
    def to_compta_rubrik(period)
      Compta::Rubrik.new(self, period)
    end
    
    
    # renvoie les numeros des rubriques feuilles
    # en éliminant les nils
    def all_instructions 
      self_and_descendants.collect(&:numeros).select {|num| num != nil}
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
    # depth = 0 pour root et on augmente le niveau quand on descend dans l'arbre
    def depth
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
    # TODO voir si utilisé 
    def complete_list(period)
      [name] + all_lines(period) + totals if leaf?
    end


    def brut(period)
      lines(period).sum {|l| l.brut(period) }
    end

    def amortissement(period)
      lines(period).sum {|l| l.amortissement(period) }
    end

    alias depreciation amortissement

    def net(period)
      (brut(period) - amortissement(period)) rescue 0.0
    end

    def previous_net(period)
      lines(period).sum { |l| l.previous_net(period) }
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
        Compta::RubrikParser.new(period, folio.sens, numeros).rubrik_lines
    end
    
    
    

end
