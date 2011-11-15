# -*- encoding : utf-8 -*-

class LinesController < ApplicationController

  before_filter :find_listing
  # GET /lines
  # GET /lines.json
  def index
    @lines = @listing.lines.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lines }
    end
  end

 

  # GET /lines/new
  # GET /lines/new.json
  def new
    @line =@listing.lines.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @line }
    end
  end

  # GET /lines/1/edit
  def edit
    @line = @listing.lines.find(params[:id])
  end

  # POST /lines
  # POST /lines.json
  def create
    @line = @listing.lines.new(params[:line])

    respond_to do |format|
      if @line.save
        format.html { redirect_to listing_lines_url(@listing), notice: 'La ligne a été créée.' }
        format.json { render json: @line, status: :created, location: @line }
      else
        format.html { render action: "new" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /lines/1
  # PUT /lines/1.json
  def update
    @line = @listing.lines.find(params[:id])

    respond_to do |format|
      if @line.update_attributes(params[:line])
        format.html { redirect_to [@listing,@line], notice: 'Line was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lines/1
  # DELETE /lines/1.json
  def destroy
    @line = @listing.lines.find(params[:id])
    @line.destroy

    respond_to do |format|
      format.html { redirect_to listing_lines_url(@listing) }
      format.json { head :ok }
    end
  end

  private
  def find_listing
    @listing=Listing.find(params[:listing_id])
    @organism=@listing.organism
  end
end
