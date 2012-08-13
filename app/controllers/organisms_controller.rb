# -*- encoding : utf-8 -*-

class OrganismsController < ApplicationController

  skip_before_filter :find_organism, :current_period

  # renvoie vers new s'il n'y pas d'organisme
  # et vers show s'il n'y a qu'un seul organisme
  # si plus d'un affiche la vue par défaut
  def index 
    @room_organisms = current_user.rooms.collect do |r|
      {:organism=>r.organism, :room=>r, :archive=>(r.look_for {Archive.last}) }
    end
  end
 
  # GET /organisms/1 test watcher
  # GET /organisms/1.json
  def show
    @current_user = current_user
    @organism = Organism.find(params[:id])
    if @organism.periods.empty?
      flash[:alert]= 'Vous devez créer au moins un exercice pour cet organisme'
      redirect_to new_admin_organism_period_url(@organism)
      return
    end
  
    current_period
    # Ce min est nécessaire car il y a un problème avec les soldes si la date du jour est postérieure à la date de clôture
    # du dernier exercice - probablement il faut trouver plus élégant
    @date=[@organism.periods.last.close_date, Date.today].min

    # Construction des éléments des paves
    @paves=[]
    @paves += @organism.books.all.reject {|b| b.class.name == 'OdBook'}
    @paves << @period
    @paves += @organism.bank_accounts.all.select {|ba| ba.bank_extracts.any? }
    @paves += @organism.cashes.all
    
  end

end
