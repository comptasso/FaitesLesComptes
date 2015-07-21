# coding: utf-8

module Admin::RoomHelper


  # donne le statut du holder de la room pour l'utilisateur actuel
  def holder_status(organism)

    I18n.t(organism.user_status(current_user))
  end

end
