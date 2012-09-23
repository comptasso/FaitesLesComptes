# coding: utf-8

require 'book.rb'

class BankAccountBook < Book
  
  attr_accessor :bank_account

  belongs_to :organism

  def lines
    bank_account.lines
  end

  def sold_at(date = Date.today)
    - super
  end

  def monthly_value(selector)
    if selector.is_a?(String)
      selector = Date.civil(selector[/\d{4}$/].to_i, selector[/^\d{2}/].to_i,1)
    end
    # on arrête la courbe au mois en cours
    return sold_at(selector.end_of_month)  unless selector.beginning_of_month.future?
  end

end
