# -*- encoding : utf-8 -*-

require 'change_period' #lib/change_period


class Admin::PeriodsController < Admin::ApplicationController

  logger.debug 'dans Admin::PeriodsController'
  # ChangePeriod ajoute la méthode change, méthode partagée par les différents PeriodsController
  # Voir le fichier lib/change_period.rb.
  #
  # Change a pour effet de changer d'exercice et de revenir à l'action initiale.
  # Dans le cas où cette action a des paramètres mois et an, change recalcule des
  # nouveaux paramètres adaptés à l'exercice sélectionné.
  #
  include ChangePeriod

  # GET /periods
  # GET /periods.json
  def index
    @periods = @organism.periods
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @periods }
    end
  end

  
  # GET /periods/new
  # GET /periods/new.json
  def new
     if @organism.periods.any?
      @disable_start_date = true
      start_date = (@organism.periods.last.close_date) +1
      # begin_year and end_year limit the select in the the view
      @begin_year = start_date.year
      @end_year = @begin_year + 2 #
    else
      @disable_start_date = false
      @begin_year = @end_year = nil
      start_date = Date.today.beginning_of_year # on propose une date d'ouverture par défaut
    end
    close_date = start_date.years_since(1)-1 # et une date de clôture probable
    @period = @organism.periods.new(:start_date=>start_date, :close_date=>close_date)
    
  end

 

  # POST /periods
  # POST /periods.json
  # le controller remplit start_date s'il y a un exercice précédent
  def create
    start_date = (@organism.periods.last.close_date) +1 if @organism.periods.any?
    @period = @organism.periods.new(params[:period])
    @period.start_date = start_date
    respond_to do |format|
      if @period.save
        session[:period]=@period.id
        format.html { redirect_to admin_organism_periods_path(@organism), notice: "L'exercice a été créé et vous travaillez actuellement dans ce nouvel exercice" }
        format.json { render json: @period, status: :created, location: @period }
      else
        format.html { render action: "new" }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  

  # DELETE /periods/1
  # DELETE /periods/1.json
  def destroy
    @period = Period.find(params[:id])
    if @period.destroy
      session[:period] = @organism.periods.any? ? @organism.periods.last : nil
      flash[:notice] = 'L\'exercice a été détruit ; vous avez changé d\'exercice'
    end
    respond_to do |format|
      format.html do
          redirect_to admin_organism_periods_url(@organism)
      end
      format.json { head :ok }
    end
  end

  # TODO - vérifier qu'il n'y a pas de problème lorsqu'on crée un exercice
  # après les avoir supprimé tous. (est-ce que les comptes sont bien créés)
   
  # action de cloture d'un exercice
  def close
    if @period.close
       flash[:notice] = 'L\'exercice est maintenant clos'
       redirect_to admin_organism_periods_url(@organism)
    else
     # construction du message d'alerte
     alert = "#{@period.exercice} ne peut être clos : \n"
     @period.errors[:close].each {|message| alert += '- ' + message + "\n"}
     flash[:alert]= alert
     # et retour à la vue index
     @periods=@organism.periods
     render :index
    end
  end


end
