# coding: utf-8

require 'pdf_document/default.rb'

module Editions

  # La classe Stats fille de PdfDocument::Totalized permet l'édition pdf
  # des StatsNatures.
  #
  # Cette classe utilise le template de Totalized pour l'affichage
  #
  # fetch_lines est surchargé car les lignes sont déjà obtenues par StatsNatures
  # et prepare_line l'est également car les lignes sont également mise en forme.
  #
  # Un aspect particulier est le fait que l'on doive limiter les mois à 12
  # pour les exercices supérieurs à 12 mois.
  #
  # Dans l'immédiat on fait la tranche des 12 derniers mois.
  #
  class Stats < PdfDocument::Totalized

    def initialize(period, stats)
      super(period, stats, {})
      @from_date = period.start_date
      @to_date = period.close_date
      @title = 'Statistiques par nature'
      
      # stats est la méthode qui renvoie les stats
      # TODO voir si lines ne serait pas plus performant; mais probablement sans aucune
      # utilité puisque fetch_lines fonctionne à partir de la source
      @select_method = 'stats'
   
      plm = period.list_months.collect {|my| my}
      plm = plm.slice(-12,12) if plm.size > 12
      @subtitle = "De #{plm.first.to_format('%B %Y')} à #{plm.last.to_format('%B %Y')}"

      set_columns [:id, :name]
      set_columns_titles(['Natures'] + plm.collect {|my| my.to_format('%b %y')} + ['Total'])
      set_columns_alignements([:left] + plm.collect{:right} + [:right]) # à gauche pour les natures et à droite pour les mois et la colonne Total
      larg_col_num = 6.5
      set_columns_widths([100 - (1 + plm.length)*larg_col_num] + plm.collect {larg_col_num } + [larg_col_num])
      set_columns_to_totalize(1.upto(1 + plm.length).collect {|i| i})
    end

   
    # comme les lignes sont déja calculées par Stats#stats,
    # il n'est pas utile d'appeler la base.
    #
    # Dans la méthode source renvoie à stats qui a servi à l'initialisation
    #
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      source.twelve_months_lines.slice(offset, limit)
    end

    def prepare_line(line)
        line
    end

  end
end