class MaskField < ActiveRecord::Base
  belongs_to :mask, inverse_of: :mask_fields
  attr_accessible :content, :label
  
  # commenté car ne fonctionne pas avec accepts_nested_attributes_for
  validates :mask, :presence=>true
  
  
end
