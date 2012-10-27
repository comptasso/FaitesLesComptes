# coding: utf-8

module Compta

  # la classe MonthlyLedger permet d'imprimer le journal centralisateur
  # pour un mois donné.
  # Une ligne Mois de ...
  # suivie d'une ligne avec 4 colonnes
  # Abbréviation du jl, Intitulé, Débit, Crédit
  # Puis une ligne de sous total
  # le MonthlyLedger se construit avec un period et un MonthYear
   class MonthlyLedger 

     def initialize(period, my)
       @period = period
       @month_year = my
     end

     # renvoie la ligne de titre, par exemple : Mois de janvier 2013
     def title_line
       {title:'', description:"Mois de #{@month_year.to_format('%B %Y')}", debit:'', credit:''}
       
     end

     # prend les livres dans l'ordre alphabétique et fait un tableau
     # avec le titre du journal(VE ou OD), la description, le total_debit et le total_credit
     def lines
       @lines ||= @period.books.map do |b|
        efb =  Extract::FromBook.new(b, @month_year)
         {title:b.title, description:b.description, debit:efb.total_debit, credit:efb.total_credit }
       end
     end

     def total_debit
       @lines.inject(0) {|t, l| t+= l[:debit] }
     end

     def total_credit
       @lines.inject(0) {|t, l| t+= l[:credit] }
     end

     def total_line
       {title:'', description:"Sous total #{@month_year.to_format('%B %Y')}", debit:total_debit, credit:total_credit}
     end
   end
end
