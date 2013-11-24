# coding: utf-8
module Extract
#
# un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
# se créé en appelant new avec un book et une date quelconque du mois souhaité
#
# La seule différence avec CashExtract réside dans les arguments de new qui
# sont la caisse et les paramètres d'un mois#
#
class MonthlyCash < Extract::Cash
  
  def initialize(virtual_book, h)
    @book = virtual_book
    @my = MonthYear.new(h)
    @begin_date = @my.beginning_of_month
    @period = @book.organism.find_period(@begin_date)
    @end_date = @my.end_of_month
  end
  
  
end
  

end
