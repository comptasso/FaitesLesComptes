# coding: utf-8

require 'month_year'


module Extract


  # un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
  # se créé en appelant new avec un book et un hash permettant de définir un MonthYear
  # my_hash est un hash :year=>xxxx, :month=>yy
  class MonthlyInOut < Extract::InOut

    def initialize(book, my_hash)
      @my = MonthYear.new(my_hash)
      begin_date = @my.beginning_of_month
      end_date = begin_date.end_of_month
      period = book.organism.find_period(begin_date)
      super(book, period, begin_date, end_date )
    end

      
    def subtitle
      @my.to_format('%B %Y')
    end

     

  end


end
