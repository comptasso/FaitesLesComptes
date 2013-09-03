class Admin::MasksController < ApplicationController
  # GET /admin/masks
  # GET /admin/masks.json
  def index
    @admin_masks = @organism.masks.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_masks }
    end
  end

  # GET /admin/masks/1
  # GET /admin/masks/1.json
  def show
    @admin_mask = Admin::Mask.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_mask }
    end
  end

  # GET /admin/masks/new
  # GET /admin/masks/new.json
  def new
    @admin_mask = @organism.mask.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_mask }
    end
  end

  # GET /admin/masks/1/edit
  def edit
    @admin_mask = Admin::Mask.find(params[:id])
  end

  # POST /admin/masks
  # POST /admin/masks.json
  def create
    @admin_mask = @organism.mask.new(params[:admin_mask])

    respond_to do |format|
      if @admin_mask.save
        format.html { redirect_to @admin_mask, notice: 'Mask was successfully created.' }
        format.json { render json: @admin_mask, status: :created, location: @admin_mask }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_mask.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/masks/1
  # PUT /admin/masks/1.json
  def update
    @admin_mask = Admin::Mask.find(params[:id])

    respond_to do |format|
      if @admin_mask.update_attributes(params[:admin_mask])
        format.html { redirect_to @admin_mask, notice: 'Mask was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_mask.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/masks/1
  # DELETE /admin/masks/1.json
  def destroy
    @admin_mask = Admin::Mask.find(params[:id])
    @admin_mask.destroy

    respond_to do |format|
      format.html { redirect_to admin_masks_url }
      format.json { head :no_content }
    end
  end
end
