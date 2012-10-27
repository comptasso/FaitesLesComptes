# coding: utf-8

module Compta

  # la classe GeneralLedger (journal général) permet d'imprimer le journal centralisateur
  # reprenant mois par mois les soldes des différentes journaux
  # le GeneralLedger se construit avec un period et s'appuie sur MonthlyLedger
   class GeneralLedger 
      def initialize(period)
        @period = period
      end

      # les lignes d'un journal général ne sont que la compilation des lignes des différents
      # MonthlyLedger du period
      def lines
        tableau = []
        @period.list_months.map do |my|
          cml = Compta::MonthlyLedger.new(@period, my)
          tableau << cml.title_line
          cml.lines.each {|l| tableau << l}
          tableau << cml.total_line
        end
        tableau
      end
   end
end
