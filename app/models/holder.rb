class Holder < ActiveRecord::Base
  attr_accessible :room_id, :status, :user_id
  
  belongs_to :room
  belongs_to :user
end
