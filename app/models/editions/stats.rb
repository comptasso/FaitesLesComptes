# coding: utf-8

require 'pdf_document/default.rb'

module Editions

  # La classe Stats fille de PdfDocument::Totalized permet l'édition pdf
  # des StatsNatures.
  #
  # Le classe se crée avec un exercice et une source de données, en l'occurence des
  # StatsNature
  #
  # Cette classe utilise le template de Totalized pour l'affichage
  #
  # La source doit répondre à lines pour renvoyer les lignes
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

    def initialize(period, source)
      super(period, source, {})
      @from_date = period.start_date
      @to_date = period.close_date
      @title = 'Statistiques par nature'
      
      # stats est la méthode qui renvoie les stats
      @select_method = 'stats'
   
      plm = last_twelve_months
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
    #
    # twelve_months_lines est une méthode protégée destinée à limiter l'édition sur
    # 12 mois pour des problèmes de mise en page.
    #
    # TODO voir à traiter ça plus élégamment qu'en tronquant les données.
    #
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      fls = source.lines.slice(offset, limit)
      twelve_months_lines(fls)
    end

    def prepare_line(line)
        line
    end


    protected

    # on ne garde que 12 mois
    def last_twelve_months
      plm = @period.list_months.collect {|my| my}
      plm = plm.slice(-12,12) if plm.size > 12
      plm
    end

    # cette méthode est rendue nécessaire pour l'édition de pdf car la mise en
    # page est prévue pour 12 mois.
    #
    # On tronque donc le tableau s'il y a plus de 12 mois.
    def twelve_months_lines(collection)
      return collection if collection.first.size <= 14
      # on prend les colonnes 0 (le libellé) et les 13 dernières
      collection.collect {|l| l.slice(0,1) + l.slice(-13,13)}
    end


  end
end