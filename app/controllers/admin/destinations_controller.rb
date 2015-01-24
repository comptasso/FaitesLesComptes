# -*- encoding : utf-8 -*-

class Admin::DestinationsController < Admin::ApplicationController

# TODO faire le spec de ce controller
  
  # GET /destinations
  # GET /destinations.json
  def index
    @destinations = @organism.destinations.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @destinations }
    end
  end

  
  # GET /destinations/new
  # GET /destinations/new.json
  def new
    @destination = @organism.destinations.new
    @destination.sector_id = @organism.sectors.first.id
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @destination }
    end
  end

  # GET /destinations/1/edit
  def edit
    @destination = @organism.destinations.find(params[:id])
  end

  # POST /destinations
  # POST /destinations.json
  def create
    @destination = @organism.destinations.new(destination_params)

    respond_to do |format|
      if @destination.save
        format.html { redirect_to admin_organism_destinations_path(@organism),
          notice: "L'activité #{@destination.name} a été créée." }
        
        format.json { render json: @destination, status: :created, location: @destination }
      else
        format.html { render action: "new" }
        format.json { render json: @destination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /destinations/1
  # PUT /destinations/1.json
  def update
    @destination = @organism.destinations.find(params[:id])

    respond_to do |format|
      if @destination.update_attributes(destination_params)
        format.html { redirect_to admin_organism_destinations_path(@organism), 
          notice: "L'activité #{@destination.name} a été mise à jour." }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @destination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /destinations/1
  # DELETE /destinations/1.json
  def destroy
    @destination = @organism.destinations.find(params[:id])
    @destination.destroy

    respond_to do |format|
      format.html { redirect_to admin_organism_destinations_url }
      format.json { head :ok }
    end
  end
  
  private
  
  def destination_params
    params.require(:destination).permit(:name, :comment, 
      :income_outcome, :sector_id)
  end
  
end
