class BankAccount < ActiveRecord::Base
  belongs_to :organism
  has_many :check_deposits
  has_many :lines, through: :organism

  def sold
    ls= self.lines.bank
    return ls.sum(:credit)-ls.sum(:debit)
  end

end
