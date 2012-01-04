# -*- encoding : utf-8 -*-
class CashesController < ApplicationController

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
