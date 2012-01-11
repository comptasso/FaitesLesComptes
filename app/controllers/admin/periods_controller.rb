# -*- encoding : utf-8 -*-


class Admin::PeriodsController < Admin::ApplicationController

  

  # GET /periods
  # GET /periods.json
  def index
    @periods = @organism.periods.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @periods }
    end
  end

  def show
    @period=Period.find(params[:id])
    session[:period]=@period.id
    redirect_to admin_organism_periods_path(@organism)
  end

  

  # GET /periods/new
  # GET /periods/new.json
  def new
    @start_date_picker=false
    if @organism.periods.any?
      start_date=(@organism.periods.last.close_date) +1
      @start_date_picker=true
    else
      start_date=Date.today.beginning_of_year
    end
    close_date=start_date.years_since(1)-1
    @period = @organism.periods.new(:start_date=>start_date, :close_date=>close_date)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @period }
    end
  end

  # GET /periods/1/edit
  def edit
    @period = Period.find(params[:id])
  end

  # POST /periods
  # POST /periods.json
  def create
    params[:period][:start_date] = (@organism.periods.last.close_date + 1.day) unless @organism.periods.count == 0
    @period = @organism.periods.new(params[:period])
    
    respond_to do |format|
      if @period.save
         session[:period]=@period.id
        format.html { redirect_to admin_organism_periods_path(@organism), notice: "L'exercice a été créé" }
        format.json { render json: @period, status: :created, location: @period }
      else
        format.html { render action: "new" }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /periods/1
  # PUT /periods/1.json
  def update
    @period = Period.find(params[:id])

    respond_to do |format|
      if @period.update_attributes(params[:period])
         session[:period]=@period.id
        format.html { redirect_to admin_organism_periods_path(@organism), notice: "L'exercice a été modifié" }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /periods/1
  # DELETE /periods/1.json
  def destroy
    @period = Period.find(params[:id])
    @period.destroy

    respond_to do |format|
      format.html { redirect_to admin_organism_periods_url }
      format.json { head :ok }
    end
  end

  # action destinée à afficher un formulaire permettant de choisir un plan comptable
  # pour l'instant il n'y a qu'un seul plan comptable, stocké dans la partie assets/plan
  # A terme, il faudrait pouvoir importer un plan par un fichier du type csv.
  def select_plan
    @period = @organism.periods.find(params[:id])
  end

  def create_plan
    @period = @organism.periods.find(params[:id])
   nb_accounts=Utilities::PlanComptable.new.create_accounts(@period.id, params[:fichier])
    flash[:notice] = "#{nb_accounts} comptes ont été créés"
    
  rescue
    flash[:alert] = "Erreur dans la création des comptes"
  ensure
    redirect_to admin_organism_period_accounts_path(@organism,@period)
  end
end
