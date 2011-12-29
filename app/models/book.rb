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

end
