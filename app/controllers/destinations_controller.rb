# -*- encoding : utf-8 -*-

class DestinationsController < ApplicationController
  before_filter :find_organism

  # GET /destinations
  # GET /destinations.json
  def index
    @destinations = @organism.destinations.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @destinations }
    end
  end

  # GET /destinations/1
  # GET /destinations/1.json
  def show
    @destination = @organism.destinations.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @destination }
    end
  end

 
end
