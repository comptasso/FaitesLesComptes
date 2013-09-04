class Mask < ActiveRecord::Base
  belongs_to :organism
  has_many :mask_fields, :dependent=>:destroy
  
  accepts_nested_attributes_for :mask_fields
  
  attr_accessible :comment, :title
  
  validates :title, :organism_id, presence:true
  validates :title, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
end
