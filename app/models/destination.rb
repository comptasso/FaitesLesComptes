class Destination < ActiveRecord::Base
  belongs_to :organism
  has_many :lines
  validates :organism_id, :presence=>true
end
