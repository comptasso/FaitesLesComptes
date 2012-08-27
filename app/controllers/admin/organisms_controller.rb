# -*- encoding : utf-8 -*-

class Admin::OrganismsController < Admin::ApplicationController
  # GET /organisms
  # GET /organisms.json

  skip_before_filter :find_organism, :current_period, only:[:index, :new] 
  before_filter :use_main_connection, only:[:index, :new, :destroy]

  

  # liste les organismes appartenant au current user
  # si certains organismes n'ont pas de base de données permettant de lire l'organisme
  # affiche une alerte indiquant les bases non trouvées
  def index
    session[:org_db]=nil
    rooms = current_user.rooms.map {|r| r.organism_description}
    @room_organisms = rooms.select {|o| o != nil}
    unless rooms.select {|o| o == nil}.empty?
      list = current_user.rooms.select {|r| r.organism == nil}.collect {|r| r.database_name}.join(', ')
      flash[:alert] = "Base de données non trouvées : #{list}"
    end
  end

  # GET /organisms/1
  # GET /organisms/1.json
  def show
    @organism = Organism.find(params[:id])
    if @organism.periods.empty?
      flash[:alert]= 'Vous devez créer un exercice pour cet organisme'
      redirect_to new_admin_organism_period_url(@organism)
      return
    end
    # on trouve l'exercice à partir de la session mais si on a changé d'organisme
    # session[:period] aura été mis à nil
    # il faut alors charger le dernier exercice par défaut et l'affecter à la session
    begin
      @period = @organism.periods.find(session[:period])
    rescue
      @period = @organism.periods.last
      session[:period]=@period.id
    end
  
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @organism }
    end
  end

  # GET /organisms/new
  # GET /organisms/new.json
  def new
    @organism = Organism.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organism }
    end
  end

  # GET /organisms/1/edit
  def edit
    @organism = Organism.find(params[:id])
  end

  # POST /organisms
  # POST /organisms.json
  def create
    @organism = Organism.new(params[:organism])
       if @organism.valid?
        # on crée une room pour le user qui a créé cette base
       current_user.rooms.create!(:database_name => params[:organism][:database_name])
       @organism.create_db
       use_org_connection(@organism.database_name) # normalement inutile car build_room reste sur la toute nouvelle base
       @organism.save
       session[:org_db]  = @organism.database_name
       redirect_to new_admin_organism_period_url(@organism), notice: "Création de l'organisme effectuée, un livre des recettes et un livre des dépenses ont été créés.\n
          Il vous faut maintenant créer un exercice pour cet organisme" 
      else
         render action: "new" 
      end
   
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

  # DELETE /organisms/1
  # DELETE /organisms/1.json
  def destroy
    @organism = Organism.find(params[:id])
    if @organism.destroy
      session[:period] = nil
      redirect_to admin_organisms_url
    else
      render
    end
    
  end

 
end
