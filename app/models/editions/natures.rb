# coding: utf-8

require 'pdf_document/default.rb'

module Editions

  class Natures < PdfDocument::Totalized


    def initialize(period, filter = 0)
      super(period, period, :select_method=>'natures', :subtitle=>'Bonsoir') do
        @title = 'Statistiques par nature'
#        @from_date = period.start_date
#        @to_date = period.close_date
#        @subtitle = "Du #{I18n.l @from_date} au #{@to_date}"
      end
      set_columns [:name, "compta_lines.mois_with_writings(@period.list_months.first).sum('credit_debit') AS val1"]
      set_columns_widths([50, 50]) # [22] + 13.times.map {6})
      set_columns_methods [:name, :name]
#      @default
    end

    def nb_pages
      [@source.send(@select_method).count/@nb_lines_per_page.to_f, 1].max
    end
      
      
    

#    def prepare_line
#      []
#    end

end
end