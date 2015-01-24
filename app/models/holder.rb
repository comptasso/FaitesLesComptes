class Holder < ActiveRecord::Base
  # attr_accessible :room_id, :status, :user_id
  
  belongs_to :room
  belongs_to :user
  
  validates :room_id, :user_id, presence:true
  validates :status, :inclusion=>{:in=>%w(owner guest)}
 
end
