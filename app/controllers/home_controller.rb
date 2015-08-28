class HomeController < ApplicationController

  skip_before_action :authenticate_tenant!, :only=>[:index]

  def index
    if user_signed_in?
      # pour être certain qu'un flash s'affiche si il y a eu un précédent
      # message
      flash[:notice] = flash[:error] unless flash[:error].blank?
      session[:org_id] = nil
      case current_user.organisms.count
      when 0
        flash[:notice]=premier_accueil(current_user)
        redirect_to new_admin_organism_url
      when 1
        @organism = current_user.organisms.first
        session[:org_id] = @organism.id
        redirect_to organism_url(@organism)
      else
        redirect_to admin_organisms_url
      end
    else
      redirect_to new_user_session_path
    end

  end
end
