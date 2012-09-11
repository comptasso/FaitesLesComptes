# coding: utf-8

require 'book.rb'

class CashBook < Book
  

  def monthly_value(selector)
    -  super
  end

  def sold_at(date = Date.today)
    - super
  end

end
