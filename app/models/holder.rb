class Holder < ActiveRecord::Base

  # acts_as_tenant
  belongs_to :organism
  belongs_to :user
  belongs_to :room

  validates :organism_id, :user_id, presence:true
  validates :status, :inclusion=>{:in=>%w(owner guest)}

end
