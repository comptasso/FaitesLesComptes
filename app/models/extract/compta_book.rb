# coding: utf-8

require 'month_year'

module Extract


  # un extrait d'un livre donné avec capacité à calculer les totaux et les soldes.
  # se crée avec deux paramètres : le livre et l'exercice.
  #
  # Cette classe est utilisée pour afficher les extraits de livre dans un mode
  # comptable, à savoir avec les données des writings et pour chaque writings
  # les compta_lines associées.
  # 
  # Elle se comporte donc globalement comme Extract::Book mais ses lignes sont 
  # composées de writings et des compta_lines de ces writings d'où une méthode
  # supplémentaires (#writings) pour lire les écritures et non plus seulement les 
  # compta_lines.
  #
  class ComptaBook < Extract::Book
    
    # Renvoie les writings du livre. Utilisé pour la vue index de l'affichage 
    # des livres dans la partie compta.
    # TODO on peut surement accélérer l'affichage de la vue en faisant un 
    # include compta_lines.
    def writings
      @book.writings.laps(from_date, to_date)
    end

   
    # produit le document pdf en s'appuyant sur la classe Editions::Book
    def to_pdf      
      Editions::ComptaBook.new(lines_collection, 
        {title:title, subtitle:subtitle, organism_name:book.organism.title, exercice:@period.long_exercice}) do |ecb|
        ecb.columns_widths = [10, 60, 15, 15]
        ecb.columns_titles = %w(Compte Libellé Débit Crédit)
        ecb.columns_to_totalize = [2, 3]
        ecb.columns_alignements = [:left, :left, :right, :right]
        ecb.subtitle = subtitle
      end
    end

    protected
    
    
    # crée un array d'objet qui est composé des writings et de leur compta_lines
    #
    # Successivement un writing, puis les compta_lines de ce writing, 
    # puis un autre writings puis les compta_lines.
    # 
    def lines_collection
      writings.map do |w|
        [w] +   w.compta_lines
      end.flatten
    end

  
    
    #  Utilisé pour l'export vers le csv et le xls
    # 
    # Prend une ligne comme argument et renvoie un array avec les différentes valeurs
    # préparées : date est gérée par I18n::l, les montants monétaires sont reformatés poru
    # avoir 2 décimales et une virgule,...
    # 
    # On ne tronque pas les informations car celà est destiné à l'export vers un fichier csv ou xls
    # 
    def prepare_line(line)
      [I18n::l(line.writing.date), line.writing.id, line.writing.ref, line.writing.narration, 
           line.account.number, line.account.title, french_format(line.debit), french_format(line.credit)]
    end

    # est un proxy de ActionController::Base.helpers.number_with_precicision
    # TODO faire un module qui gère ce sujet car utile également pour table.rb
    def french_format(r)
      return '' if r.nil?
      return ActionController::Base.helpers.number_with_precision(r, :precision=>2)  if r.is_a? Numeric
      r
    end

  end

end
