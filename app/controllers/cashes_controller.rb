# -*- encoding : utf-8 -*-
class CashesController < ApplicationController

  before_filter :find_organism,  :current_period

  # GET /cashes
  # GET /cashes.json
  def index
    @cashes = @organism.cashes.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cashes }
    end
  end

  # GET /cashes/1
  # GET /cashes/1.json
  def show
    @cash = Cash.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cash }
    end
  end

 
end
