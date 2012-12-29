# -*- encoding : utf-8 -*-

# Cette classe agit comme un proxy pour accéder aux organismes qui sont dans
# des bases séparées (Room étant par contre dans la base commune).
# Ce controller est nécessaire car autrement dans les vues où il y a plusieurs organismes
# ces organismes ont l'id  1 (puisqu'ils sont seuls dans leur base).
# Pour des vues de type index et pour les actions, il faut donc passer par rooms
class Admin::RoomsController < Admin::ApplicationController

  skip_before_filter :find_organism, :current_period
    
  # trouve la pièce demandée, connecte la base
  # trouve l'organisme de cette base
  # et redirige vers le controller organism
  def show
    @room = current_user.rooms.find(params[:id])
    organism_has_changed?(@room)
    redirect_to admin_organism_path(@organism)
  end

  
  def edit
    @room = current_user.rooms.find(params[:id])
    organism_has_changed?(@room)
    redirect_to edit_admin_organism_path(@organism)
  end

  # action qui permet de créer une nouvelle archive lorsque l'on affiche la liste des
  # organismes
  def new_archive
    @room = current_user.rooms.find(params[:id])
    organism_has_changed?(@room)
    redirect_to new_admin_organism_archive_path(@organism) 
  end

  # détruit la pièce ainsi que la base associée
  # cette méthode n'appelle pas set_database car tout se passe dans la base principale
  def destroy
    @room = current_user.rooms.find(params[:id])
    abs_db = @room.absolute_db_name
    db_name= @room.db_filename
    Rails.logger.info "Destruction de la base #{db_name}  - méthode rooms_controller#destroy}"
  
    if @room.destroy
      # on détruit le fichier correspondant
      # FIXME sur windows au moins, semble poser un problème de droit d'accès
      # donc on n'efface pas le fichier
      #  File.delete(abs_db) if File.exist?(abs_db)
      flash[:notice] =  "La base #{db_name} a été supprimée"
      organism_has_changed?
      redirect_to admin_organisms_url
    else
      flash[:alert] = "Une erreur s'est produite; la base  #{db_name} a été supprimée"
      render 'show'
    end
  end


  
end
