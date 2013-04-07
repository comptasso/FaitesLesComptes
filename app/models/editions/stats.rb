# coding: utf-8

require 'pdf_document/default.rb'

module Editions

  class Stats < PdfDocument::Totalized


    def initialize(period, stats, filter = 0)
      super(period, stats, {})
      @from_date = period.start_date
      @to_date = period.close_date
      @title = 'Statistiques par nature'
      @subtitle = "Du #{I18n.l @from_date} au #{@to_date}"
      @select_method = 'stats'
      @template =  "#{Rails.root}/app/models/editions/prawn/#{self.class.name.split('::').last.downcase}.pdf.prawn.rb"

      plm = period.list_months.to_abbr_with_year
      set_columns [:id, :name]
      set_columns_titles(['Natures'] + plm + ['Total'])
      set_columns_alignements([:left] + plm.collect{|c| :right} + [:right]) # à gauche pour les natures et à droite pour les mois et la colonne Total
      set_columns_widths([100 - (1 + plm.length)*6] + plm.collect {|c|  6 } + [6])
      set_columns_to_totalize(1.upto(plm.size).collect {|i| i})
    end

    # comme les lignes sont déja calculées par Stats#stats,
    # il n'est pas utile d'appeler la base
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      source.lines.slice(offset, limit)
    end

      def prepare_line(line)
         line
      end

  end
end