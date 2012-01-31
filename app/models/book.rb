class Book < ActiveRecord::Base

  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold
  
  belongs_to :organism
  has_many :lines, dependent: :destroy
 
  
  validates :title, presence: true

#  def book_type
#    nil
#  end
#
#  def book_type=(type)
#    nil
#  end


end
