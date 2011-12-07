# -*- encoding : utf-8 -*-

class OrganismsController < ApplicationController
  # GET /organisms
  # GET /organisms.json
  def index
    @organisms = Organism.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organisms }
    end
  end

  # GET /organisms/1
  # GET /organisms/1.json
  def show
    @organism = Organism.find(params[:id])

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

    respond_to do |format|
      if @organism.save
        format.html { redirect_to @organism, notice: "Création de l'organisme effectuée" }
        format.json { render json: @organism, status: :created, location: @organism }
      else
        format.html { render action: "new" }
        format.json { render json: @organism.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /organisms/1
  # PUT /organisms/1.json
  def update
    @organism = Organism.find(params[:id])

    respond_to do |format|
      if @organism.update_attributes(params[:organism])
        format.html { redirect_to @organism, notice: "Modification de l'organisme effectuée" }
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
    @organism.destroy

    respond_to do |format|
      format.html { redirect_to organisms_url }
      format.json { head :ok }
    end
  end

  def stats
    @date_from = params[:pick_date_from] ? picker_to_date(params[:pick_date_from]) : Date.today.beginning_of_year
    @date_to = params[:pick_date_to] ? picker_to_date(params[:pick_date_to]) : Date.today.end_of_year
    @organism=Organism.find(params[:id])
    @lines = @organism.lines.includes(params[:by]).select("destination_id, sum(debit) as debit, sum(credit) as credit").group("destination_id")
    @total_debit=0
    @total_credit=0

  end
end
