class Admin::MasksController < Admin::ApplicationController
  # GET /admin/masks
  # GET /admin/masks.json
  def index
    @masks = @organism.masks.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_masks }
    end
  end

  # GET /admin/masks/1
  # GET /admin/masks/1.json
  def show
    @mask = Mask.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mask }
    end
  end

  # GET /admin/masks/new
  # GET /admin/masks/new.json
  def new
    @mask = @organism.masks.new
    @mask.book_id = @organism.outcome_books.first.id # on choisit par défaut un livre de dépenses
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mask }
    end
  end

  # GET /admin/masks/1/edit
  def edit
    @mask = Mask.find(params[:id])
  end

  # POST /admin/masks
  # POST /admin/masks.json
  def create
    @mask = @organism.masks.new(admin_mask_params)

    respond_to do |format|
      if @mask.save
        format.html { redirect_to admin_organism_mask_url(@organism, @mask), notice: 'Le masque de saisie a été créé' }
        format.json { render json: @mask, status: :created, location: @mask }
      else
        format.html { render action: "new" }
        format.json { render json: @mask.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/masks/1
  # PUT /admin/masks/1.json
  def update
    @mask = Mask.find(params[:id])

    respond_to do |format|
      if @mask.update_attributes(admin_mask_params)
        format.html { redirect_to admin_organism_mask_url(@organism, @mask), notice: 'Le masque de saisie a été mis à jour' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mask.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/masks/1
  # DELETE /admin/masks/1.json
  def destroy
    @mask = Mask.find(params[:id])
    @mask.destroy

    respond_to do |format|
      format.html { redirect_to admin_organism_masks_url(@organism) }
      format.json { head :no_content }
    end
  end
  
  private
  
  def admin_mask_params
    params.require(:mask).permit(:comment, :title, :book_id, :ref, :narration, 
    :destination_id, :nature_name, :mode, :amount, :counterpart)
  end
end
