# coding: utf-8

require 'pdf_document/pdf_rubriks'

module Compta

  # Rubriks est une classe comportant un titre et une collection répondant aux
  # méthodes brut, amortissement, net et previous net
  # ainsi que totals qui fournit alors une ligne avec les différentes valeurs voulues
  # total_actif, total_passif permet de choisir la présentation (avec brut et amortissement)
  # totals_prefix rajoute Total au titre pour pouvoir l'identifier lors des export en csv.
  #
  # Rubriks est concçue pour pouvoir être récursif, même si en pratique on n'utilise
  # que deux niveaux dans les éditions.
  #
  # la méthode lines permet en effet d'afficher les différentes lignes de la collection
  # en appelant leur fonction totals
  #
  class Rubriks
    attr_reader :collection, :title

    def initialize(period, title, collection)
      @period = period
      @collection = collection
      @title = title.to_s
    end

    # la ligne de total avec son titre et ses 3 valeurs
    def totals
      [@title, brut, amortissement, net, previous_net]
    end

    def total_actif
      [@title, brut, amortissement, net, previous_net]
    end

    def total_passif
      [@title, net, previous_net]
    end

    def totals_prefix(prefix = 'Total ')
      v = totals
      v[0] = prefix + v[0].to_s
      v
    end

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
