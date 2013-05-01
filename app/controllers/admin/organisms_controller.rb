# -*- encoding : utf-8 -*-

class Admin::OrganismsController < Admin::ApplicationController

  class NomenclatureError < StandardError; end

  skip_before_filter :find_organism, :current_period, only:[:index, :new] 
  before_filter :use_main_connection, only:[:index, :new, :destroy]

  after_filter :clear_org_cache, only:[:create, :update]

  
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

  

  # PUT /organisms/1
  # PUT /organisms/1.json
  def update
    @organism = Organism.find(params[:id])

    respond_to do |format|
      if @organism.update_attributes(params[:organism])

        format.html { redirect_to [:admin, @organism], notice: "Modification de l'organisme effectuée" }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @organism.errors, status: :unprocessable_entity }
      end
    end
  end



#  # DELETE /organisms/1
#  # DELETE /organisms/1.json
#  def destroy
#    @organism = Organism.find(params[:id])
#    if @organism.destroy
#      session[:period] = session[:org_db] = nil
#
#
#      redirect_to admin_organisms_url
#    else
#      render
#    end
#
#  end

  protected

  
   # appelé par after_filter pour effacer les caches utilisés pour l'affichage
   # des menus
   def clear_org_cache
     Rails.cache.clear("saisie_#{current_user.name}")
     Rails.cache.clear("admin_#{current_user.name}")
     Rails.cache.clear("compta_#{current_user.name}")
   end

 
end
