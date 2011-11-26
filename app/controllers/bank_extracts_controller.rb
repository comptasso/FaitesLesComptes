# -*- encoding : utf-8 -*-

class BankExtractsController < ApplicationController

  before_filter :find_listing_and_organism


  # GET /bank_extracts
  # GET /bank_extracts.json
  def index
    @bank_extracts = @listing.bank_extracts.all
    if @bank_extracts.size == 0
      redirect_to new_listing_bank_extract_url(@listing)
      return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bank_extracts }
    end
  end

 

  # GET /bank_extracts/new
  # GET /bank_extracts/new.json
  def new

    @bank_extract = @listing.bank_extracts.build(begin_sold: @listing.extract_sold)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bank_extract }
    end
  end

  # GET /bank_extracts/1/edit
  def edit
    @bank_extract = BankExtract.find(params[:id])
  end

  # POST /bank_extracts
  # POST /bank_extracts.json
  def create
    @bank_extract = BankExtract.new(params[:bank_extract])

    respond_to do |format|
      if @bank_extract.save
        format.html { redirect_to listing_bank_extracts_path(@listing), notice: "L'extrait de compte a été créé." }
        format.json { render json: @bank_extract, status: :created, location: @bank_extract }
      else
        format.html { render action: "new" }
        format.json { render json: @bank_extract.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bank_extracts/1
  # PUT /bank_extracts/1.json
  def update
    @bank_extract = BankExtract.find(params[:id])

    respond_to do |format|
      if @bank_extract.update_attributes(params[:bank_extract])
        format.html { redirect_to listing_bank_extracts_path(@listing), notice: "L'extrait a été modifié " }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @bank_extract.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_extracts/1
  # DELETE /bank_extracts/1.json
  def destroy
    @bank_extract = BankExtract.find(params[:id])
    @bank_extract.destroy

    respond_to do |format|
      format.html { redirect_to listing_bank_extracts_url(@listing) }
      format.json { head :ok }
    end
  end

  private

  def find_listing_and_organism
    @listing=Listing.find(params[:listing_id])
    @organism=@listing.organism
  end
end
