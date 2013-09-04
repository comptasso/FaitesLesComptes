class Mask < ActiveRecord::Base
  belongs_to :organism
  attr_accessible :comment, :title
  
  validates :title, :organism_id, presence:true
  validates :title, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
end
