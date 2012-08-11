class User < ActiveRecord::Base

  establish_connection Rails.env

  has_many :rooms

  def enter_first_room
    rooms.first
  end

  # retourne une liste de tous les organisms appartenat à cet user
  def organisms_with_room
    rooms.collect { |r| {organism:r.organism, room:r} }
  end

 

  
end
