# coding: utf-8

require 'book.rb'

class IncomeBook < IncomeOutcomeBook

  has_many :in_out_writings,  foreign_key:'book_id'

  def income_outcome
    true
  end
end
