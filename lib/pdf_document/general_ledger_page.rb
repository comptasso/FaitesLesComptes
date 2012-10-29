# coding: utf-8

  require 'pdf_document/page.rb'

  # la classe GeneralLedgerPage construit une page du journal général
  # Elle répond donc aux méthodes exigées par default.pdf.prawn
  # Elle est appelée par general_ledger

  # PdfDocument::Page apporte toutes les méthodes nécessaires, il suffit donc de
  # surcharger les méthodes spécifiques
   class PdfDocument::GeneralLedgerPage < PdfDocument::Page
      
      def initialize(document, list_monthly_ledgers, number)
        @number = number
        @doc = document
        @list_monthly_ledgers = list_monthly_ledgers
      end

      def last_page?
        @number == @doc.nb_pages
      end

     
      def table_title
        %w(Mois Journal Libellé Debit Credit)
      end

    # FIXME mettre les valeurs réelles
      def table_total_line
        ['Totaux'] + formatted_values(total_page_values)
      end

      def table_to_report_line
        [last_page? ? 'Totaux généraux' : 'A reporter'] + formatted_values(to_report_values)
      end

      def table_report_line
        return nil if @number == 1
        ['Reports'] + formatted_values(report_values)
      end

      # totalise les débit des livres de cette page
      def total_debit
        @list_monthly_ledgers.inject(0.0) {|t, ml| t += ml.total_debit}
      end

      # totalise les credits des livres de cette page
      def total_credit
        @list_monthly_ledgers.inject(0.0) {|t, ml| t += ml.total_credit}
      end


      # forunit le report
#     def table_report_line
#      return nil if @number == 1 # première page
#      r =  @doc.page(@number -1).table_to_report_line
#      r[0] = 'Reports'
#      r
#    end

     # renvoie le tableau des lignes préparées
     def table_lines
       fetch_lines.map do |l|
         [l[:mois], l[:title], l[:description],format_value(l[:debit]), format_value(l[:credit])]
       end
     end

     # récupère les différentes lignes de chaque monthly ledger de la page
     # TODO voir comment on différencie le résultat en terme de style des lignes
     # Faire un to_pdf pour chaque MonthlyLedger
     def fetch_lines
       tableau = []
        @list_monthly_ledgers.each do |ml|
          tableau << ml.title_line
          ml.lines.each {|l| tableau << l}
          tableau << ml.total_line
        end
        tableau
     end

    

     def total_page_values
       [total_debit, total_credit]
     end

     def report_values
       return [0, 0] if @number == 1
       @doc.page(@number -1).to_report_values
     end

     def to_report_values
        [total_page_values[0] + report_values[0], total_page_values[1] + report_values[1]]
     end

     def formatted_values(arr)
       arr.map {|v| format_value(v)}
     end

     def format_value(r)
       return '%0.2f' % r if r.is_a? BigDecimal
       return '%0.2f' % r if r.is_a? Float
       r
     end




   end


