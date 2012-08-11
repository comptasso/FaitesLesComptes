# -*- encoding : utf-8 -*-


class Admin::PeriodsController < Admin::ApplicationController

  # skip_before_filter :current_period

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
    @disable_start_date = true
    @begin_year = @end_year = nil
    if @organism.periods.any?
      start_date=(@organism.periods.last.close_date) +1
      # begin_year and end_year limit the select in the the view
      @begin_year = start_date.year
      @end_year = @begin_year + 2 #
    else
      @disable_start_date = false
      start_date=Date.today.beginning_of_year
    end
    close_date=start_date.years_since(1)-1 
    @period = @organism.periods.new(:start_date=>start_date, :close_date=>close_date)
    
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
  # TODO ceci pourrait être dans un controller plan
  def select_plan
    @period = @organism.periods.find(params[:id])
  end


  # POST création du plan comptable après le select_plan
  def create_plan
    @period = @organism.periods.find(params[:id])
    nb_accounts=Utilities::PlanComptable.new.create_accounts(@period.id, params[:fichier])
    flash[:notice] = "#{nb_accounts} comptes ont été créés"
    
  rescue
    flash[:alert] = "Erreur dans la création des comptes"
  ensure
    redirect_to admin_organism_period_accounts_path(@organism,@period)
  end

  def archive
     tmp_file="#{Rails.root}/tmp/#{@organism.title}_#{@period.exercice}.jcl"
      # Créer un fichier : y écrirer les infos de l'exercice
      File.open(tmp_file, 'w') do |f|
        f.write @organism.to_yaml
        f.write @period.to_yaml
        f.write @organism.destinations.all.to_yaml
        f.write @organism.natures.all.to_yaml
        f.write @organism.bank_accounts.all.to_yaml
        @organism.bank_accounts.all.each do |b|
          f.write b.bank_extracts.all.to_yaml
          b.bank_extracts.all.each do |be|
            f.write be.bank_extract_lines.all.to_yaml
          end
          f.write b.check_deposits.all.to_yaml
        end
        f.write @organism.books.all.to_yaml
        @organism.books.all.each do |b|
          f.write b.lines.all.to_yaml
        end
        f.write @organism.cashes.all.to_yaml
        @organism.cashes.all.each do |c|
          f.write c.cash_controls.all
        end
        f.write @period.accounts.all.to_yaml
      end

    send_file tmp_file, type: 'application/jcl'
     
  end

 
  # action de cloture d'un exercice
  # problématique de confirmation
  def close
    if @period.closable?
      @period.close
      redirect_to admin_organism_period_path(@period, @period)
    else
     @periods=@organism.periods
     alert= "#{@period.exercice} ne peut être clos : \n"
     @period.errors[:close].each {|e| alert += '- ' + e + "\n"}
     flash[:alert]= alert
     render :index
    end

  end


end
