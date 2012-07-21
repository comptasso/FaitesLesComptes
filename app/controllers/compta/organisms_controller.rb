# -*- encoding : utf-8 -*-

class Compta::OrganismsController < Compta::ApplicationController
  
  # GET /organisms/1
  # GET /organisms/1.json
  def show
    reset_session if (params[:id] != session[:organism])
    @organism = Organism.find(params[:id])
    session[:organism] = @organism.id if @organism
    
    if @organism.periods.empty?
      flash[:alert]= 'Vous devez créer un exercice pour cet organisme'
      redirect_to new_admin_organism_period_url(@organism)
      return
    end
    # on trouve l'exercice à partir de la session mais si on a changé d'organisme
    # il faut changer la session et on charge le dernier exercice par défaut
    begin
      @period = @organism.periods.find(session[:period])
    rescue
      @period = @organism.periods.select {|p| p.accountable? }.last
      session[:period]=@period.id
    end
    redirect_to new_compta_period_balance_path(@period)
   
  end

  

 
end
