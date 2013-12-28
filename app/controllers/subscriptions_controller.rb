class SubscriptionsController < ApplicationController
  
  def create
    sub = Subscription.find(params[:subscription][:id])
        
    if sub && sub.late?
      uw = Utilities::Writer.new(sub)
      count = 0
      sub.month_year_to_write.each do |my|
        count += 1 if uw.write(my)
      end
      flash[:notice] = "#{view_context.pluralize(count, 'écriture')} 
#{view_context.jc_pluralize(count, 'a', 'ont')} été #{view_context.jc_pluralize(count, 'générée')} par l'écriture périodique '#{sub.title}'"
    else
      flash[:alert] = "Ecriture périodique '#{sub.title}' n'a pas d'écritures à passer" if sub
      flash[:alert] = 'Ecriture périodique non trouvée' unless sub
    end
    
    redirect_to :back
  end
   
end