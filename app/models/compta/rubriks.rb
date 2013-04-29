# coding: utf-8

require 'pdf_document/pdf_rubriks.rb'

require 'compta/rubrik'

module Compta

  # Rubriks est une classe comportant un titre et une collection répondant aux
  # méthodes brut, amortissement, net et previous net
  # ainsi que totals qui fournit alors une ligne avec les différentes valeurs voulues
  # total_actif, total_passif permet de choisir la présentation (avec brut et amortissement)
  # totals_prefix rajoute Total au titre pour pouvoir l'identifier lors des export en csv.
  #
  # Rubriks est concçue pour pouvoir être récursif, même si en pratique on n'utilise
  # que deux ou trois niveaux dans les éditions.
  #
  # la méthode lines permet en effet d'afficher les différentes lignes de la collection
  # en appelant leur fonction totals
  #
  class Rubriks
    attr_reader :collection, :title

    def initialize(period, title, collection)
      @period = period
      @title = title.to_s
      @collection = collection
    end

    # la ligne de total avec son titre et ses 4 valeurs
    def totals
      [@title, brut, amortissement, net, previous_net]
    end

    # total_actif est similaire à totals
    alias total_actif totals

    # total_passif prend les données du total 
    # mais ne conserve que ce qui est nécessaire pour afficher une page de
    # type passif (titre, veleur nette et valeur nette de l'exercice précédent.
    def total_passif
      [@title, net, previous_net]
    end

    # Permet de préfixer la ligne en rajoutant une string (par défaut Total )
#    def totals_prefix(prefix = 'Total ')
#      v = totals
#      v[0] = prefix + v[0].to_s
#      v
#    end

    # le montant brut total de la collection
    def brut
      @collection.sum(&:brut)
    end

    # le montant des amortissements ou dépreciation
    def amortissement
      @collection.sum(&:amortissement)
    end

    alias depreciation amortissement

    # le montant net de la collection
    def net
      @collection.sum(&:net)
    end

    # le montant net de l'exercice précédent
    def previous_net
      @collection.sum(&:previous_net)
    end

    # retourne un array des différents éléments de la collection avec leurs totaux
    def lines
      @collection.collect {|r| r.totals}
    end

    # détermine sa profondeur (utile) pour sélectionner les styles dans
    # les vues ou les pdf, en fonction de celle de sa collection
    def depth
      @collection.first.depth + 1 
    end


    # Utilisé pour les vues de détail de Sheet,
    # permet de récupérer les Rubriks, les Rubrik et les RubrikLine
    #
    # Fetch_lines est récursif tant que la class est une Compta::Rubriks
    #
    def fetch_lines
      fl = []
      @collection.each do |c|
        
        fl += c.fetch_lines if c.class == Compta::Rubriks
        fl += c.lines  if c.class == Compta::Rubrik && !c.lines.empty? 
        fl << c if c.class == Compta::Rubrik
      end
      fl << self
      fl
    end

    # Récupèere les différentes Ribriks
    def fetch_rubriks
      result = []
      collection.each do |c|
        
        if c.class == Compta::Rubriks
          result += c.fetch_rubriks
          # result << c
        end
      end
      result << self
    end


    # Récupère les différentes rubriks avec les sous rubriks
    # mais ne prend pas le détail des lignes
    def fetch_rubriks_with_rubrik
      result = []
      collection.each do |c|
        
        if c.class == Compta::Rubriks
          result += c.fetch_rubriks_with_rubrik
        elsif c.class == Compta::Rubrik
          result << c
        end
      end
      result << self
    end

    
    
    #produit un document pdf en s'appuyant sur la classe PdfDocument::Simple
    # et ses classe associées page et table
    def to_pdf(options = {})
      options[:title] =  "Détail de la rubrique #{@title}"
      pdf = PdfDocument::PdfRubriks.new(@period, self, options)
      pdf.set_columns(['title', 'brut', 'amortissement', 'net', 'previous_net'])
      pdf.set_columns_titles(['', 'Montant brut', "Amortissement\nProvision", 'Montant net', 'Précédent'])
      pdf.set_columns_widths([40, 15, 15, 15, 15])
      pdf.set_columns_alignements([:left, :right, :right, :right, :right] )
      pdf
    end
   





  end
end
