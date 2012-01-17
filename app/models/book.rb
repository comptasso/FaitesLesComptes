class Book < ActiveRecord::Base
  belongs_to :organism
  has_many :lines, dependent: :destroy
 
  
  validates :title, presence: true

  def book_type
    nil
  end

  def book_type=(type)
    nil
  end

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
