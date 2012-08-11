# -*- encoding : utf-8 -*-

# Cette classe agit comme un proxy pour accéder aux organismes qui sont dans
# des bases séparées (Room étant par contre dans la base commune).
# Ce controller est nécessaire car autrement dans les vues où il y a plusieurs organismes
# ces organismes ont l'id  1 (puisqu'ils sont seuls dans leur base).
# Pour des vues de type index et pour les actions, il faut donc passer par rooms
class Admin::RoomsController < Admin::ApplicationController

  skip_before_filter :find_organism, :current_period
  before_filter :use_main_connection, :find_room # défini dans application controller
  before_filter :set_database, :except=>:destroy


  # trouve la pièce demandée, connecte la base
  # trouve l'organisme de cette base
  # et redirige vers le controller organism
  def show
    redirect_to admin_organism_path(@organism)
  end

  
  def edit
    redirect_to edit_admin_organism_path(@organism)
  end

  def new_archive
    redirect_to new_admin_organism_archive_path(@organism)
  end

  # détruit la pièce ainsi que la base associée
  # cette méthode n'appelle pas set_database car tout se passe dans la base principale
  def destroy
    Rails.logger.info "Destruction de la base #{@room.database_name}  - méthode rooms_controller#destroy}"
    # on vérifie que le fichier correspondant existe
    if @room.destroy
      # on détruit le fichier correspondant
      File.delete(@room.absolute_db_name) if File.exist?(@room.absolute_db_name)
      flash[:notice] =  "La base #{@room.database_name} a été supprimée"
      session[:org_db] = nil # on efface les éléments de la session
      redirect_to admin_organisms_url
    else
      flash[:alert] = "Une erreur s'est produite; la base  #{@room.database_name} a été supprimée"
      render 'show'
    end
  end


  protected

  def find_room
    @room = current_user.rooms.find(params[:id])
  end

  def set_database
    use_org_connection(@room.database_name)
    session[:org_db]  = @room.database_name
    @organism = Organism.first
  end
end
