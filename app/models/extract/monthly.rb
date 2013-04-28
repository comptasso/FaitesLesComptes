# coding: utf-8
module Extract
#
# un extrait mensuel d'un livre existant dans une base de données ou
# d'un livre virtuel donné.
#
# Avec capacité à calculer les totaux et les soldes
#
# Se créé en appelant new avec un book et une date quelconque du mois souhaité
#
class Monthly < Extract::Base

    attr_reader :book

    def initialize(book, my)
      @book = book
      @my = my
      @date = @my.beginning_of_month
    end

    def lines
      @lines ||= @book.compta_lines.mois(@date)
    end

    def month
      @my.to_format('%B %Y')
    end

    def debit_before
      @book.cumulated_debit_before(@date)
    end

    def credit_before
      @book.cumulated_credit_before(@date)
    end

    def sold
      credit_before + total_credit - debit_before - total_debit
    end



end

end


