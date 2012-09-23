class Writing < ActiveRecord::Base
  belongs_to :book
  has_many :lines
end
