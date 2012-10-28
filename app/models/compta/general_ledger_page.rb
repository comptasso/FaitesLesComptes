# coding: utf-8



  # la classe GeneralLedgerPage construit une page du journal général
  # Elle répond donc aux méthodes exigées par default.pdf.prawn
  # Elle est appelée par general_ledger

  # PdfDocument::Page apporte toutes les méthodes nécessaires, il suffit donc de
  # surcharger les méthodes spécifiques
   class Compta::GeneralLedgerPage < PdfDocument::Page
      
      def initialize(document, list_monthly_ledgers, number)
        @number = number
        @doc = document
        @list_monthly_ledgers = list_monthly_ledgers
      end

      # le modèle n'étant pas persistant, il ne connaît pas sa date de création
      def top_right
        "#{Time.now}"
      end

      def table_title
        %w(Journal Libellé Debit Credit)
      end

    # FIXME mettre les valeurs réelles
      def table_total_line
        ['Totaux', 999, 888]
      end

      def table_to_report_line
        ['Reports', 999, 888]
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
         [l[:title], l[:description], l[:debit], l[:credit]]
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



   end


