# -*- encoding : utf-8 -*-

class NaturesController < ApplicationController

 

  # GET /natures
  # GET /natures.json
  def index
    @natures = @organism.natures.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @natures }
    end
  end

  def stats
    @filter=params[:destination].to_i || 0
    @recettes=@organism.natures.recettes
    @depenses=@organism.natures.depenses
   
  end

 
 
end
