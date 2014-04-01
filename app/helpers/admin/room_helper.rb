# coding: utf-8

module Admin::RoomHelper

 
  # donne le statut du holder de la room
  def holder_status(room, cu)
    I18n.t(room.holders.where('user_id = ?', cu.id).first.status)
  end
  
end
