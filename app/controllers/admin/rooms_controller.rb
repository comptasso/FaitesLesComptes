# -*- encoding : utf-8 -*-



# Cette classe permet de choisir le tenant que l'on souhaite
# pour les utilisateurs (expert) qui sont autorisés à
# accéder à plusieurs Tenants
#
class Admin::RoomsController < Admin::ApplicationController

  skip_before_filter :find_organism, :current_period

  after_filter :clear_org_cache

  # affiche la liste des tenants que le user peut choisir
  def index
    @tenants = current_user.tenants
  end

  # trouve l'espace (le tenant) demandé
  # et redirige vers le controller organism
  def show
    logger.debug "Changement d'espace - tenant_id actuel: #{session[:tenant_id]}"
    set_current_tenant(room_params[:id].to_i)
    redirect_to admin_organisms_path
  end

  private

  def room_params
    params.permit(:id)
  end
end
