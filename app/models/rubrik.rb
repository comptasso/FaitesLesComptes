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
    
    # Utilisé pour les vues de détail de Sheet2,
    # permet de récupérer les Rubriks, les Rubrik et les RubrikLine
    #
    # Fetch_lines est récursif tant que la class est une Compta::Rubriks
    #
    def fetch_lines(period)
      fl = []
      children.each do |c|
        
        fl += c.fetch_lines(period) unless c.leaf?
        fl += c.lines(period)  if c.leaf? && !c.lines(period).empty? 
        fl << c if c.leaf?
      end
      fl << self
      fl
    end
    
     # Récupère les différentes rubriks avec les sous rubriks
    # mais ne prend pas le détail des lignes
    def fetch_rubriks_with_rubrik
      result = []
      children.each do |c|
        
        if c.leaf? 
          result << c
        else
          result += c.fetch_rubriks_with_rubrik
        end
      end
      result << self
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
    
    #produit un document pdf en s'appuyant sur la classe PdfDocument::Simple
    # et ses classe associées page et table
    def to_pdf(options = {})
      options[:title] =  "Détail de la rubrique #{name}"
      pdf = PdfDocument::PdfRubriks.new(@period, self, options)
      pdf.set_columns(['title', 'brut', 'amortissement', 'net', 'previous_net'])
      pdf.set_columns_titles(['', 'Montant brut', "Amortissement\nProvision", 'Montant net', 'Précédent'])
      pdf.set_columns_widths([40, 15, 15, 15, 15])
      pdf.set_columns_alignements([:left, :right, :right, :right, :right] )
      pdf
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
    
    # la profondeur (depth) d'une rubrique est 0
    # cette méthode existe pour pouvoir définir la profondeur
    # des Compta::Rubriks
    # TODO avoir un calcul plus général puisqu'on a plus qu'une rubrik et non 
    # des compta::rubriks et compta::rubrik
    
    alias depth level
    
    
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
