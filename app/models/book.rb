class Book < ActiveRecord::Base
  belongs_to :organism
  has_many :lines, dependent: :destroy
  has_many :bank_extracts, dependent: :destroy

 validates :title, presence: true

 

end
