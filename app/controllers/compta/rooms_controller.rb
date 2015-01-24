# -*- encoding : utf-8 -*-

# Cette classe est exactement identique à celle de rooms controller
# et n'a qu'une action show, servant de proxy à l'application pour
# accéder à Organism#show


# TODO voir si encore utile car servait lorsqu'on changeait d'organisme
# ce qui se fait maintenant en passant par la partie Admin.
class Compta::RoomsController < Compta::ApplicationController

  skip_before_filter :find_organism, :current_period

  # trouve la pièce demandée, connecte la base
  # trouve l'organisme de cette base
  # et redirige vers le controller organism
  def show
    @room = current_user.rooms.find(params[:id])
    organism_has_changed?(@room)
    redirect_to compta_organism_path(Organism.first)
  end

end
