
# Cette classe agit comme un proxy pour accéder aux organismes qui sont dans
# des bases séparées (Room étant par contre dans la base commune).
# Ce controller est nécessaire car autrement dans les vues où il y a plusieurs organismes
# ces organismes ont l'id  1 (puisqu'ils sont seuls dans leur base).
# Pour des vues de type index et pour les actions, il faut donc passer par rooms
class Admin::RoomsController < Admin::ApplicationController

  skip_before_filter :find_organism, :current_period
  before_filter :use_main_connection
  before_filter :set_database


  # trouve la pièce demandée, connecte la base
  # trouve l'organisme de cette base
  # et redirige vers le controller organism
  def show
    redirect_to admin_organism_path(Organism.first.id)
  end

  
  def edit
     redirect_to edit_admin_organism_path(Organism.first.id)
  end

  def destroy
  end


  protected

  def set_database
    room = current_user.rooms.find(params[:id])
    use_org_connection(room.database_name)
    session[:connection_config] = ActiveRecord::Base.connection_config
  end
end
