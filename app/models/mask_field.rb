class MaskField < ActiveRecord::Base
  belongs_to :mask
  attr_accessible :content, :label
  
  validates :mask, :presence=>true
end
