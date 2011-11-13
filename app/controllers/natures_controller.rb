# -*- encoding : utf-8 -*-

class NaturesController < ApplicationController

  before_filter :find_organism

  # GET /natures
  # GET /natures.json
  def index
    @natures = @organism.natures.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @natures }
    end
  end

  # GET /natures/1
  # GET /natures/1.json
  def show
    @nature = @organism.natures.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @nature }
    end
  end

  # GET /natures/new
  # GET /natures/new.json
  def new
    @nature = @organism.natures.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @nature }
    end
  end

  # GET /natures/1/edit
  def edit
    @nature = @organism.natures.find(params[:id])
  end

  # POST /natures
  # POST /natures.json
  def create
    @nature = @organism.natures.new(params[:nature])

    respond_to do |format|
      if @nature.save
        format.html { redirect_to organism_natures_path(@organism), notice: 'La Nature a été créée.' }
        format.json { render json: @nature, status: :created, location: @nature }
      else
        format.html { render action: "new" }
        format.json { render json: @nature.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /natures/1
  # PUT /natures/1.json
  def update
    @nature = @organism.natures.find(params[:id])

    respond_to do |format|
      if @nature.update_attributes(params[:nature])
        format.html { redirect_to organism_natures_path(@organism), notice: 'Nature a été mise à jour.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @nature.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /natures/1
  # DELETE /natures/1.json
  def destroy
    @nature = @organism.natures.find(params[:id])
    @nature.destroy

    respond_to do |format|
      format.html { redirect_to organism_natures_url(@organism) }
      format.json { head :ok }
    end
  end
end
