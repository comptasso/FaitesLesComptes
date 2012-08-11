class User < ActiveRecord::Base

  has_many :rooms


  def rooms
    ActiveRecord::Base.use_main_connection
    Room.where('user_id = ?', id)
  end 

  # TODO avoir ici un active_organism qui a du sens
  def enter_first_room
    rooms.first
  end

  # retourne une liste de tous les organisms appartenat à cet user
  def organisms_with_room
    rooms.collect { |r| {organism:r.organism, room:r} }
  end

  
end
