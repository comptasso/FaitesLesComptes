# coding: utf-8

module Admin::RoomHelper

 
  # donne le statut du holder de la room
  def holder_status(room)
    I18n.t(room.holders.first.status)
  end
  
end
