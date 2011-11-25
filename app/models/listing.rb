class Listing < ActiveRecord::Base
  belongs_to :organism
  has_many :lines, dependent: :destroy
  has_many :bank_extracts, dependent: :destroy

end
