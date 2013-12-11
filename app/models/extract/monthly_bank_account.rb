# coding: utf-8
module Extract
#
# un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
# se créé en appelant new avec un book et une date quelconque du mois souhaité
#
# La seule différence avec CashExtract réside dans les arguments de new qui
# sont la caisse et les paramètres d'un mois#
#
class MonthlyBankAccount < Extract::BankAccount
  
  def initialize(cash, h)
    @book = cash
    @my = MonthYear.new(h)
    @from_date = @my.beginning_of_month
    @period = @book.organism.find_period(@from_date)
    @to_date = @my.end_of_month
  end

  
end
  

end
