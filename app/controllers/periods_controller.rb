# -*- encoding : utf-8 -*-


class PeriodsController < ApplicationController

   before_filter :find_organism

  # GET /periods
  # GET /periods.json
  def index
    @periods = @organism.periods.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @periods }
    end
  end

  

  # GET /periods/new
  # GET /periods/new.json
  def new
    if @organism.periods.any? 
      start_date=@organism.periods.last.close_date +1
    else
      start_date=Date.today.beginning_of_year
    end
    @period = @organism.periods.new(:start_date=>start_date)
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
    @period = @organism.periods.new(params[:period])

    respond_to do |format|
      if @period.save
        format.html { redirect_to organisms_periods_path(@organism), notice: "L'exercice a été créé" }
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
        format.html { redirect_to organism_periods_path(@organism), notice: "L'exercice a été modifié" }
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
      format.html { redirect_to periods_url }
      format.json { head :ok }
    end
  end
end
