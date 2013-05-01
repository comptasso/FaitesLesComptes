# -*- encoding : utf-8 -*-

# Cette classe agit comme un proxy pour accéder aux organismes qui sont dans
# des bases séparées (Room étant par contre dans la base commune).
# Ce controller est nécessaire car autrement dans les vues où il y a plusieurs organismes
# ces organismes ont l'id  1 (puisqu'ils sont seuls dans leur base).
#
# #organism_has_changed?  est défini dans application controller : vérifie s'il
# y a eu un changement d'organisme mais surtout met à jour les éléments de la
# session dans ce cas.
#


class RoomsController < ApplicationController

  skip_before_filter :find_organism, :current_period
 
  # trouve la pièce demandée, connecte la base
  # trouve l'organisme de cette base
  # et redirige vers le controller organism
  def show
    room = current_user.rooms.find(params[:id])
    organism_has_changed?(room)
    o =  Organism.first
    if o
      redirect_to organism_path(o)
    else
      redirect_to new_admin_room_path
    end
  end

end
