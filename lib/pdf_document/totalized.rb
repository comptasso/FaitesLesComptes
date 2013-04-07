# coding: utf-8

require 'pdf_document/simple'

module PdfDocument

  # la classe Totalized permet d'éditer un fichier pdf reprenant une liste d'information
  # avec des colonnes numériques qui sont totalisées.
  #
  # Et avec un report des totaux et un total final.
  # 
  # La classe descend de Simple, qui est capable de faire un pdf tabulaire 
  # mais sans totaux.
  # 
  # Ici, on rajoute des méthodes pour pouvoir définir les lignes à totaliser ainsi que
  # pour calculer la largeur des colonnes des lignes de total et de report.
  #
  class Totalized < PdfDocument::Simple

    attr_reader :columns_to_totalize
    attr_accessor :first_report_line

     def initialize(period, source, options)
      super
      @template = 'lib/pdf_document/totalized.pdf.prawn.rb'
    end


    # par rapport à la méthode héritée, prepare_line ne fait pas de mise
    # en forme automatique des champs numériques, pour pouvoir permettre la
    # totalisation.
    #
    # TODO, voir si effectivement utile car les totaux sont préparés dans les pages
    # et les tables.
    #
    def prepare_line(line)
      columns_methods.collect { |m| line.instance_eval(m) rescue nil }
    end

    # les colonnes à totaliser sont indiquées par un indice
    # par exemple si on demande Date Réf Debit Credit
    # on sélectionne [2,3] pour indices
    def set_columns_to_totalize(indices)
      
      raise ArgumentError , 'Le tableau des colonnes ne peut être vide' if indices.empty?
      @columns_to_totalize = indices
      set_total_columns_widths
    end


    # Calcule les largeurs de colonnes pour une ligne de total.
    #
    # L'objectif est de regrouper les colonnes qui ne sont pas à totaliser, a priori
    # à gauche, en une seule.
    def set_total_columns_widths
      raise 'Impossible de calculer les largeurs des lignes de total car les largeurs de la table ne sont pas fixées' unless @columns_widths
      @total_columns_widths = []
      # si la colonne est à totaliser on retourne la valeur
      # sinon on la garde et on examine la colonne suivant
      l = 0 # variable pour accumuler les largeurs des colonnes qui ne sont pas à totaliser
      Rails.logger.debug "DEBUG : Largeur des colonnes #{@columns_widths.inspect}"
      @columns_widths.each_with_index do |w,i|
        if @columns_to_totalize.include? i
          if l != 0
            @total_columns_widths << l
            l = 0
          end
          @total_columns_widths << w
        else
          l += w
        end
       # puts "Après #{i} de largeur #{w}, le tableau est maintenant #{@total_columns_widths}"
      end
      # au cas où il y ait des colonnes sans total en fin de tableau
      # on en rajoute une pour arriver à 100
      s = @total_columns_widths.sum
      @total_columns_widths << (100 -s) if s < 100
      @total_columns_widths
    end
  end

end
