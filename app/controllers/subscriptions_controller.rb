class SubscriptionsController < ApplicationController
  
  def index 
    
  end
  
  def create
    @sub = Subscription.find(params[:subscription][:id])
       
    if @sub && @sub.late?
      count = @sub.pass_writings
      @notice = "#{view_context.pluralize(count, 'écriture')} #{view_context.jc_pluralize(count, 'a', 'ont')} été #{view_context.jc_pluralize(count, 'générée')} par l'écriture périodique '#{@sub.title}'"
      flash[:notice] = @notice
    else
      flash[:alert] = "Ecriture périodique '#{@sub.title}' n'a pas d'écritures à passer" if @sub
      flash[:alert] = 'Ecriture périodique non trouvée' unless @sub
    end
    
    respond_to do |format|
      format.html  {redirect_to :back}
      format.js
    end
    
  end
   
end