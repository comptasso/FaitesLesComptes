# -*- encoding : utf-8 -*-

class OrganismsController < ApplicationController
 
  # GET /organisms/1 test watcher
  # GET /organisms/1.json
  def show
    @organism = Organism.find(params[:id])
    if @organism.periods.empty?
      flash[:alert]= 'Vous devez créer au moins un exercice pour cet organisme'
      redirect_to new_organism_period_url(@organism)
      return
    end
    # on trouve l'exercice à partir de la session mais si on a changé d'organisme
    # il faut changer la session et on charge le dernier exercice par défaut
    # TODO pas joli ce rescue général
    begin
      @period = @organism.periods.find(session[:period])
    rescue
      @period = @organism.periods.last
      session[:period]=@period.id
    end

    if @organism.number_of_non_deposited_checks > 0
      flash[:notice]= "Message : #{@organism.number_of_non_deposited_checks} chèques à déposer pour un montant total de #{two_decimals @organism.value_of_non_deposited_checks}"
    end
    
    @bank_accounts=@organism.bank_accounts.all
    @cashes=@organism.cashes.all
    @books=@organism.books.all
       
    # Ce min est nécessaire car il y a un problème avec les soldes si la date du jour est postérieure à la date de clôture
    # du dernier exercice - probablement il faut trouver plus élégant
    @date=[@organism.periods.last.close_date, Date.today].min

  
  end

 


end
