class BankExtract < ActiveRecord::Base
  belongs_to :book
  has_many :lines

  validates :begin_sold, :total_debit, :total_credit, :numericality=>true

  def end_sold
    begin_sold+total_credit-total_debit
  end

  def total_lines_debit
    self.lines.sum(:debit)
  end

  def total_lines_credit
    self.lines.sum(:credit)
  end

  def diff_debit
    self.total_debit - self.total_lines_debit
  end

  def diff_credit
    self.total_credit - self.total_lines_credit
  end

  def lines_sold
    self.total_lines_credit - self.total_lines_debit
  end

  def diff_sold
    self.begin_sold + self.lines_sold - self.end_sold
  end


end
