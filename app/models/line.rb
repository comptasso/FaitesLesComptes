class Line < ActiveRecord::Base
  belongs_to :listing
  belongs_to :destination
  belongs_to :nature
end
