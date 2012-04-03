# coding: utf-8

module Utilities::Sold

  def cumulated_debit_before(date)
    self.lines.where('line_date < ?', date).sum(:debit)
  end
  def cumulated_credit_before(date)
    self.lines.where('line_date < ?', date).sum(:credit)
  end
   def cumulated_debit_at(date)
    self.lines.where('line_date <= ?', date).sum(:debit)
  end
  def cumulated_credit_at(date)
    self.lines.where('line_date <= ?', date).sum(:credit)
  end

end
