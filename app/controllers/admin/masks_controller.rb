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
    
    @book_field = @mask.mask_fields.build(label:'Livre')
    @ref_field = @mask.mask_fields.build(label:'Réf')
    @narration_field = @mask.mask_fields.build(label:'Narration')
    @nature_field = @mask.mask_fields.build(label:'Nature')
    @destination_field = @mask.mask_fields.build(label:'Destination')
    @amount_field = @mask.mask_fields.build(label:'Montant')
    @mode_field = @mask.mask_fields.build(label:'Mode de paiement')
    @counterpart_field = @mask.mask_fields.build(label:'Contrepartie')
    

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
    @mask = @organism.masks.new(params[:mask])

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
      if @mask.update_attributes(params[:mask])
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
end
