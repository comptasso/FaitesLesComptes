# coding: utf-8

module Compta

  # la classe MonthlyLedger permet d'imprimer le journal centralisateur
  # pour un mois donné. De fait, c'est plutôt un Presenter
  #
  # Une ligne Mois de ...
  # suivie d'une ligne avec 4 colonnes
  # Abbréviation du jl, Intitulé, Débit, Crédit
  #
  # Puis une ligne de sous total
  #
  # le MonthlyLedger se construit avec un period et un MonthYear
   class MonthlyLedger 

     def initialize(period, my)
       @period = period
       @month_year = my
     end

     def lines_with_total
       lines.insert(0, ml.title_line).push(total_line)
     end

      # la taille d'un MonthlyLedger est son nombre de lignes plus une ligne de titre et une ligne de total
     def size
       lines.size + 2
     end

     protected

     # prend les livres dans l'ordre alphabétique et fait un tableau
     # avec le titre du journal(VE ou OD), la description, le total_debit et le total_credit
     # sous forme de Hash.
     #
     # les lignes qui ont débit et credit à zero ne sont pas retenues
     def lines
       @lines ||= @period.books.map do |b|
         efb =  Extract::Monthly.new(b, @month_year)
         {mois:'', title:b.title, description:b.description, debit:efb.total_debit, credit:efb.total_credit }
       end.reject {|l| l[:debit] == 0 && l[:credit] == 0}
     end



     def total_debit
       lines.inject(0) {|t, l| t+= l[:debit] } 
     end

     def total_credit
       lines.inject(0) {|t, l| t+= l[:credit] }
     end

     # renvoie la ligne de titre, (avec beaucoup de champs vides) par exemple : Mois de janvier 2013
     def title_line
       {mois:"Mois de #{@month_year.to_format('%B %Y')}", title:'', description:'', debit:'', credit:''}
     end

     # total_line donne le total d'un MonthlyLedger
     def total_line
       {mois:"Sous total #{@month_year.to_format('%B %Y')}", title:'', description:'', debit:total_debit, credit:total_credit}
     end

    
   end
end
