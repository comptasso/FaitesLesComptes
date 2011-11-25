class BankExtract < ActiveRecord::Base
  belongs_to :listing

  validates :begin_sold, :total_debit, :total_credit, :numericality=>true

  def end_sold
    begin_sold+total_credit-total_debit
  end
end
