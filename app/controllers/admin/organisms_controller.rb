# -*- encoding : utf-8 -*-

class Admin::OrganismsController < Admin::ApplicationController

  # TODO dans la vue index, il serait préférable que l'action de destrcution
  # renvoie vers l'organisme plutôt que le room et qu'une redirection soit faite par le controller
  
  class NomenclatureError < StandardError; end
  

  skip_before_filter :find_organism, :current_period, only:[:index, :new] 
  before_filter :use_main_connection, only:[:index, :new, :destroy]

  after_filter :clear_org_cache, only:[:update]

  
  # GET /organisms/1
  # GET /organisms/1.json
  def show
    # @organism et @period sont instanciés par les before_filter
    unless @period
      flash[:alert]= 'Vous devez créer un exercice pour cet organisme'
      redirect_to new_admin_organism_period_url(@organism)
      return
    end
  end

  
  # GET /organisms/1/edit
  def edit
    @organism = Organism.find(params[:id])
  end
  
   # méthode provisoire pour adaptation du plan comptable des CE aux 
  # réglement de l'ANC. 
  # TODO après un certain temps pour la transformation, à retirer. 
  def reset_folios
    @organism = Organism.find(params[:id])
    params.permit(:period_id)
    @period = @organism.periods.find(params[:period_id])
    @organism.send(:reset_folios)
    flash[:notice] = 'La nomenclature des comptes a été reconstruite'
    redirect_to admin_period_accounts_path(@period)
  end
  

  

  # PUT /organisms/1
  # PUT /organisms/1.json
  def update
    @organism = Organism.find(params[:id])

    respond_to do |format|
      if @organism.update_attributes(admin_organism_params)

        format.html { redirect_to [:admin, @organism], notice: "Modification de l'organisme effectuée" }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @organism.errors, status: :unprocessable_entity }
      end
    end
  end

  private 
   
  def admin_organism_params
    params.require(:organism).permit(:title, :comment, :siren, :postcode)
  end

 
end
