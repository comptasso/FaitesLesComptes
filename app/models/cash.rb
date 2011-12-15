class Cash < ActiveRecord::Base
  belongs_to :organism
  has_many :lines, through: :organism
end
