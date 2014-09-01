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
    # TODO retirer period puisque maintenant on remplit les rubriques avant 
    # de les utiliser?
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
    
    # remplit les valeurs d'une rubrique pour un exercice donné
    def fill_values(period)
      tcr = to_compta_rubrik(period)
      self.period_id = period.id
      self.brut = tcr.brut
      self.amortissement = tcr.amortissement
      self.previous_net = tcr.previous_net
      save
    end
    
    
    def net
      brut-amortissement
    end
    
    
    # renvoie les numeros des rubriques feuilles
    # en éliminant les nils. Utilisé dans Folio pour lister 
    # toutes les instructions servant à la construction du document
    def all_instructions 
      self_and_children.collect(&:numeros).select {|num| num != nil}
    end
    
    
    
    # lines renvoie les rubrik_lines qui construisent la rubrique
    # 
    def lines(period)
      if leaf? 
        return all_lines(period)
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
    
    
    # TODO voir si ces fonctions sont utilisées, car je pense qu'on appelle en fait 
    # les méthodes des Compta::Rubrik
    
      # retourne la ligne de total de la rubrique
#    def totals(period)
#      [name, brut(period), amortissement(period), net(period), previous_net(period)] rescue ['ERREUR', 0.0, 0.0, 0.0, 0.0]
#    end
#
#    alias total_actif totals
#
#    def total_passif(period)
#      [name, net(period), previous_net(period)]
#    end

    # crée un array avec le titre suivi de l'ensemble des lignes suivi de la ligne de total
    # TODO voir si utilisé 
#    def complete_list(period)
#      [name] + all_lines(period) + totals if leaf?
#    end


#    def brut(period)
#      lines(period).sum {|l| l.brut(period) }
#    end
#
#    def amortissement(period)
#      lines(period).sum {|l| l.amortissement(period) }
#    end
#
#    alias depreciation amortissement
#
#    def net(period)
#      (brut(period) - amortissement(period)) rescue 0.0
#    end
#
#    def previous_net(period)
#      lines(period).sum { |l| l.previous_net(period) }
#    end

       
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
    
    def self_and_children
      result = []
      children.each do |ch|
        if ch.leaf?
          result << ch
        else
          result += ch.self_and_children
        end
        
      end
      result << self
      result.flatten
      result
    end
    
    
    

end
