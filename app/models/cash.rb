class Cash < ActiveRecord::Base
  belongs_to :organism
  has_many :lines
  has_many :cash_controls

  def sold
    ls= self.lines
    return ls.sum(:credit)-ls.sum(:debit)
  end

end
