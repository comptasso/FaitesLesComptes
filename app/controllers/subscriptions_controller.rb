class SubscriptionsController < ApplicationController
  
  def index 
    @late_subscriptions = Subscription.all.select(&:late?)
    flash.now[:notice] = 'Pas d\'écriture à passer pour les abonnements existants' if @late_subscriptions.empty?
  end
  
  def create
    
    @sub = Subscription.find(subscription_params[:id])
       
    if @sub && @sub.late?
      count = @sub.pass_writings
      @notice = "#{view_context.pluralize(count, 'écriture')} #{view_context.jc_pluralize(count, 'a', 'ont')} été #{view_context.jc_pluralize(count, 'générée')} par l'abonnement '#{@sub.title}'"
    else
      @error = "Ecriture périodique '#{@sub.title}' n'a pas d'écritures à passer" if @sub
      @error = 'Ecriture périodique non trouvée' unless @sub
    end
    
    respond_to do |format|
      format.js
    end
    
  end
  
  private
  
  def subscription_params
    params.require(:subscription).permit(:id)
  end
end