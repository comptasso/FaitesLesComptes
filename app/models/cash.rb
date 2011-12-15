class Cash < ActiveRecord::Base
  belongs_to :organism
  has_many :lines, through: :organism

  def sold
    ls= self.lines.cash
    return ls.sum(:credit)-ls.sum(:debit)
  end

end
