# coding: utf-8
require 'pdf_document/default.rb'
require 'pdf_document/general_ledger_page.rb'

module Compta 
  # la classe GeneralLedger (journal général) permet d'imprimer le journal centralisateur
  # reprenant mois par mois les soldes des différentes journaux
  # le GeneralLedger se construit avec un period et s'appuie sur la classe MonthlyLedger
   class PdfGeneralLedger < PdfDocument::Default

     include Compta::GeneralInfo
     attr_reader :pages

      def initialize(period) 
        @period = period
        @title  = 'Journal Général'
        @subtitle = @period.open ? 'Provisoire' : 'Définitif'
        @columns_widths =  [15.0, 15.0, 40.0, 15.0, 15.0]  # cinq colonnes
        @total_columns_widths = [70.0, 15.0, 15.0]
        @columns_alignements = [:left, :left, :left, :right, :right]
        @stamp = @period.open ? 'Provisoire' : ''
        @created_at = Time.now
        set_pages
      end

      # retourne la collection de monthly_ledgers avec un cache
      def monthly_ledgers
        @monthly_ledgers ||= @period.monthly_ledgers
      end

      # calcule et définit les pages du general ledger, l'ensemble des pages
      # est un hash avec comme clé un numéro de page et comme valeur un
      # range d'integer qui correspondent à l'index du tableau des monthly_ledgers
      # On suppose qu'il n'y a aucun list_months avec plus de lignes que la
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
          if nbl >  NB_PER_PAGE_LANDSCAPE
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

      # la méthode page retourne les PdfDocument::GeneralLedgerPage
      # correspondant à la page demandée.
      #
      # On crée un PdfDocument::GeneralLedgerPage avec le Compta::PdfGeneralLedger,
      # la liste des monthly_ledger, et le numéro de la page
      #
      # TODO puisqu'on envoie self, alors le deuxième argument est redondant
      #
      def page(n)
        PdfDocument::GeneralLedgerPage.new(self,  @pages[n].map {|i| monthly_ledgers[i]}, n)
      end



   end

end