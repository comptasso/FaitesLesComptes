class Admin::BridgesController < Admin::ApplicationController
  def show
    @bridge = @organism.bridge
  end
  
  def edit
    @bridge = @organism.bridge
  end
  
  def update
    @bridge = @organism.bridge
    if @bridge.update_attributes(params[:bridge])
      flash[:notice] = 'Les paramètres ont été modifiés'
      redirect_to admin_organism_bridge_url(@organism)
    else
      flash[:alert] = 'Impossible d\'enregistrer les paramètres'
      render action: 'edit'
    end
    
    
  end
end
