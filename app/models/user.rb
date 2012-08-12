class User < ActiveRecord::Base

  establish_connection Rails.env
  
  has_many :rooms

  validates :name, presence:true

  def enter_first_room
    rooms.first
  end

  # retourne un hash des organismes et des chambres appartenat à cet user
  def organisms_with_room
    rooms.collect { |groom| {organism:groom.organism, room:groom} }
  end

  def accountable_organisms_with_room
   rs =  rooms.select {|groom| groom.look_forg { "accountable?"} }
   rs.collect { |groom| {organism:groom.organism, room:groom} }
  end

 

  
end
