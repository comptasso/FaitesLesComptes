# coding: utf-8
class OutcomeBook < IncomeOutcomeBook
  
  has_many :in_out_writings,  foreign_key:'book_id'

  def income_outcome
    false
  end
end