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
      unless @bridge.check_nature_name
      flash[:alert] = "Attention, un exercice ouvert ne dispose pas de ce nom de nature. <br/>
        L'enregistrement des paiements des adhérents sera alors impossible pour ce ou ces exercices.<br/>
        Nous vous conseillons d'harmoniser le nom de la nature pour tous les exercices ouverts".html_safe
      end
       redirect_to admin_organism_bridge_url(@organism)
    else
      flash.now[:alert] = 'Impossible d\'enregistrer les paramètres'
      render action: 'edit'
    end
    
    
  end
end
