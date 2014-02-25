# coding: utf-8

module Admin::RoomHelper

# TODO à supprimer car inutilisé
#  def jour(modele)
#    if modele
#      return I18n.l(modele.created_at)
#    else
#      return ''
#    end
#  end
  
  # donne le statut du holder de la room
  def holder_status(room, cu)
    I18n.t(room.holders.where('user_id = ?', cu.id).first.status)
  end

end
