# coding: utf-8

module Compta

  

  # la classe GeneralLedger (journal général) permet d'imprimer le journal centralisateur
  # reprenant mois par mois les soldes des différentes journaux
  # le GeneralLedger se construit avec un period et s'appuie sur MonthlyLedger
   class GeneralLedger

     include Compta::GeneralInfo
     attr_reader :pages

      def initialize(period)
        @period = period
        set_pages
      end

      def title
        'Journal Général'
      end

      def subtitle
        ''
      end

      # quatre colonnes
      def columns_widths
        [15.0,55.0,15.0,15.0]
      end

      def total_columns_widths
        [70.0,15.0,15.0]
      end


      
      # retourne la collection de monthly_ledgers 
      def monthly_ledgers
        @monthly_ledgers ||= @period.list_months.map {|my| Compta::MonthlyLedger.new(@period, my)}
      end

      # calcule et définit les pages du general ledger, l'ensemble des pages
      # est un hash avec comme clé un numéro de page et comme valeur un
      # range d'integer qui correspondent à l'index du tableau des monthly_ledgers
      # ON suppose qu'il n'y a aucun list_months avec plus de lignes que la
      # constante NB_PER_PAGE_LANDSCAPE
      def set_pages
        @pages = {}
        i = 1
        nbl = 0
        last = nil
        from = 0
        @period.list_months.each_with_index do |my, j|
          raise 'Trop grand nombre de journaux' if monthly_ledgers[j].size > NB_PER_PAGE_LANDSCAPE
          nbl += monthly_ledgers[j].size
          if nbl > NB_PER_PAGE_LANDSCAPE
            @pages[i] = from..last # on fixe les paramètres de la page
            nbl = 0
            i +=  1 # on passe à la page suivante
            from = j
          end
        last = j
        end
        @pages[i] = from..last # pour finaliser la série avec les derniers
      end

      def nb_pages
        @pages.size
      end

      def first_report_line
        ['', '', '', '']
      end

      def columns_alignements
        [:left, :left, :right, :right]
      end

      # la méthode page retourne les MonthlyLedger permettant de
      # tenir sur une page en mode paysage
      def page(n)
        Compta::GeneralLedgerPage.new(self,  @pages[n].map {|i| monthly_ledgers[i]}, n)
      end

      # Crée le fichier pdf associé
     def render(template = "lib/pdf_document/default.pdf.prawn")
       text  =  ''
       File.open(template, 'r') do |f|
          text = f.read
       end
#       puts text
       require 'prawn'
       doc = self # doc est utilisé dans le template
       pdf_file = Prawn::Document.new(:page_size => 'A4', :page_layout => :landscape) do |pdf|
            pdf.instance_eval(text)
          end
       pdf_file.number_pages("page <page>/<total>",
        { :at => [pdf_file.bounds.right - 150, 0],:width => 150,
               :align => :right, :start_count_at => 1 })
       pdf_file.render
     end


   end
end
