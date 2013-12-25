class Subscription < ActiveRecord::Base
  attr_accessible :day, :end_date, :mask_id, :organism_id, :title
end
