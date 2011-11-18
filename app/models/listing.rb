class Listing < ActiveRecord::Base
  belongs_to :organism
  has_many :lines, dependent: :destroy
end
