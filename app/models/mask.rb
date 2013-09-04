class Mask < ActiveRecord::Base
  belongs_to :organism
  has_many :mask_fields, inverse_of: :mask, :dependent=>:destroy
  
  accepts_nested_attributes_for :mask_fields
  
  attr_accessible :comment, :title, :mask_fields_attributes
  
  validates :title, :organism_id, presence:true
  validates :title, :format=>{with:NAME_REGEX}, :length=>{:within=>LONG_NAME_LENGTH_LIMITS}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true

end
