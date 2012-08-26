class User < ActiveRecord::Base

  establish_connection Rails.env
  
  has_many :rooms, :dependent=>:destroy

  validates :name, presence:true

  def enter_first_room
    rooms.first
  end

  # retourne un hash des organismes et des chambres appartenat à cet user
  # le hash ne comprend que les organimes qui ont pu être effectivement trouvés
  def organisms_with_room
    owrs = rooms.collect { |r| {organism:r.organism, room:r} }
    owrs.select {|o| o[:organism] != nil}
  end

  def accountable_organisms_with_room
   rs =  rooms.select {|groom| groom.look_forg { "accountable?"} }
   rs.collect { |groom| {organism:groom.organism, room:groom} }
  end

 

  
end
