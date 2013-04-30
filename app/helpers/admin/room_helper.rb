# coding: utf-8

module Admin::RoomHelper

  def jour(modele)
    if modele
      return I18n.l(modele.created_at)
    else
      return ''
    end
  end

end
