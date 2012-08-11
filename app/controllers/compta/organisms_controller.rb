# -*- encoding : utf-8 -*-

class Compta::OrganismsController < Compta::ApplicationController
  
  # GET /organisms/1
  # GET /organisms/1.json
  def show
    
    @organism = Organism.find(params[:id])
   
    
    if @organism.periods.empty?
      flash[:alert]= 'Vous devez créer un exercice pour cet organisme'
      redirect_to new_admin_organism_period_url(@organism)
      return
    end

    # action par défaut # peut être à revoir
    redirect_to new_compta_period_balance_path(@period)
   
  end

  

 
end
