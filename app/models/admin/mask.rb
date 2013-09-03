class Admin::Mask < ActiveRecord::Base
  belongs_to :organism
  attr_accessible :comment, :title
end
