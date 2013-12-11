# coding: utf-8

require 'month_year'


module Extract


  # un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
  # se créé en appelant new avec un book et un hash permettant de définir un MonthYear
  # my_hash est un hash :year=>xxxx, :month=>yy
  class MonthlyInOut < Extract::InOut

    def initialize(book, my_hash)
      @book = book
      @my = MonthYear.new(my_hash)
      @from_date = @my.beginning_of_month
      @to_date = @my.end_of_month
      @period = book.organism.find_period(@from_date)
    end

      
    def subtitle
      @my.to_format('%B %Y')
    end

     

  end


end
