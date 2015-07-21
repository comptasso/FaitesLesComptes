class Holder < ActiveRecord::Base
  # attr_accessible :room_id, :status, :user_id

  acts_as_tenant
  belongs_to :organism
  belongs_to :user

  validates :organism_id, :user_id, presence:true
  validates :status, :inclusion=>{:in=>%w(owner guest)}

end
