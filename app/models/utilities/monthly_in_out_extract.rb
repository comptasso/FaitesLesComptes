# coding: utf-8

require 'month_year'


module Utilities


  # un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
  # se créé en appelant new avec un book et un hash permettant de définir un MonthYear
  # my_hash est un hash :year=>xxxx, :month=>yy
  class MonthlyInOutExtract < Utilities::InOutExtract

    def initialize(book, my_hash)
      @book = book
      @my = MonthYear.new(my_hash)
      @begin_date = @my.beginning_of_month
      @end_date = @begin_date.end_of_month
      @period = @book.organism.find_period(@begin_date)
    end

      
    def month
      @my.to_format('%B %Y')
    end

     

  end


end
