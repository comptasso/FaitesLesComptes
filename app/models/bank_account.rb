class BankAccount < ActiveRecord::Base
  belongs_to :organism
  has_many :check_deposits
  has_many :lines

  def sold
    ls= self.lines
    return ls.sum(:credit)-ls.sum(:debit)
  end

end
