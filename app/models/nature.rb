class Nature < ActiveRecord::Base
  belongs_to :organism
  validates :organism_id, :presence=>true
end
