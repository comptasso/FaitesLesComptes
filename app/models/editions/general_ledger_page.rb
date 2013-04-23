# coding: utf-8

  require 'pdf_document/page.rb'

module Editions

  # la classe GeneralLedgerPage construit une page du journal général
  # Elle répond donc aux méthodes exigées par default.pdf.prawn.
  #
  # Elle est appelée par Compta::PdfGeneralLedger avec comme argument :
  #  self qui devient le document,
  #  une liste de monthly_ledgers
  #  et n : le numéro de page 
  #
  # La particularité du general_ledger est d'avoir des sous totaux au sein de 
  # la page et qu'ils ne faut donc pas compter deux fois les mêmes choses. 
  #
  # PdfDocument::Page apporte toutes les méthodes nécessaires, il suffit donc de
  # surcharger les méthodes spécifiques
   class GeneralLedgerPage < PdfDocument::Page

          
      def initialize(document, list_monthly_ledgers, number)
        @number = number
        @document = document
        @list_monthly_ledgers = list_monthly_ledgers
      end

          
      def table_title
        %w(Mois Journal Libellé Debit Credit)
      end

      # forunit la ligne de total de la page
      def table_total_line
        format_line ['Totaux', total_debit, total_credit]
      end

      # surcharge de la méthode qui fournit la ligne à reporter report (ou de total général
      # si c'est la dernière page
      def table_to_report_line
        format_line([last_page? ? 'Totaux généraux' : 'A reporter'] + to_report_values)
      end

      # surcharge de la ligne de report (la première ligne du tableau)
      def table_report_line
        return nil if number == 1
        format_line(['Reports'] + report_values)
      end



     # Renvoie le tableau des lignes préparées pour l'impression.
     #
     # french_format, qui est définie dans PdfDocument::Page permet d'avoir
     # une impression avec la virgule comme séparateur décimal et un espace pour
     # les milliers.
     #
     def table_lines
       fetch_lines.map do |l|
         [l[:mois], l[:title], l[:description],french_format(l[:debit]), french_format(l[:credit])]
       end
     end

     protected

      # totalise les débit des livres de cette page
      def total_debit
        list_monthly_ledgers.inject(0.0) {|t, ml| t += ml.total_debit}
      end

      # totalise les credits des livres de cette page
      def total_credit
        list_monthly_ledgers.inject(0.0) {|t, ml| t += ml.total_credit}
      end


     # récupère les différentes lignes de chaque monthly ledger de la page
     # TODO voir comment on différencie le résultat en terme de style des lignes
     # Faire un to_pdf pour chaque MonthlyLedger
     def fetch_lines
       tableau = []
        list_monthly_ledgers.each do |ml|
          # TODO mettre cette série d'instructions dans le monthly_ledger.(par exemple lines_with_totals)
          tableau << ml.title_line
          ml.lines.each {|l| tableau << l}
          tableau << ml.total_line
        end
        tableau
     end

     # Calcule le total de la page (débit et crédit)
     #
     def total_page_values
       [total_debit, total_credit]
     end


     # TODO une erreur dans cette méthode n a pas été détectée
     # par les spec (@doc au lieu de document)
     def report_values
       return [0, 0] if number == 1
       document.page(number()-1).to_report_values
     end

     def to_report_values
        [total_page_values[0] + report_values[0], total_page_values[1] + report_values[1]]
     end

     def list_monthly_ledgers
       @list_monthly_ledgers
     end


   end

end
