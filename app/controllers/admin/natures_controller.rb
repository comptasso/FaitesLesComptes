# -*- encoding : utf-8 -*-

class Admin::NaturesController < Admin::ApplicationController
  
  before_filter :find_income_outcome_books, only:[:index, :edit, :new]  


  # GET /natures
  # GET /natures.json
  def index 
    
  end

  # reorder est appelé par le drag and drop de la vue . Les paramètres
  # transmis sont les suivants :
  #
  #  - id :- id of the row that is moved. This information is set in the id attribute of the TR element.
  #  - fromPosition : initial position of the row that is moved. This was value in the indexing cell of the row that is moved.
  #  - toPosition : new position where row is dropped. This value will be placed in the indexing column of the row.
  #  
  # Plutôt que de faire un render de la table, reorder renvoie ok ou bad_request
  # et laisse javascript mettre à jour la vue, en l'occurence juste réécrire les positions
  # puisque il n'y a que ça de changé.
  def reorder
    @nature = Nature.find(params[:id])
    from_position = params[:fromPosition].to_i
    to_position = params[:toPosition].to_i
    if from_position > to_position
      # on remonte vers le haut de la liste
      (from_position - to_position).times { @nature.move_higher }
    else
      (to_position - from_position).times { @nature.move_lower }
    end
    head :ok
  rescue
    head :bad_request
  end

 

 
  # GET /natures/new
  # GET /natures/new.json
  def new    
    @nature = @period.natures.new
    @nature.book_id = @books.first.id
  end

  # GET /natures/1/edit
  def edit
    
    @nature = @period.natures.find(params[:id])
  end

  # POST /natures
  # POST /natures.json
  def create
    @nature = @period.natures.new(params[:nature])

    respond_to do |format|
      if @nature.save
        format.html { redirect_to admin_organism_period_natures_path(@organism, @period), notice: 'La Nature a été créée.' }
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
    @nature = @period.natures.find(params[:id])

    respond_to do |format|
      if @nature.update_attributes(params[:nature])
        format.html { redirect_to admin_organism_period_natures_path(@organism, @period), notice: 'Nature a été mise à jour.' }
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
    @nature = @period.natures.find(params[:id])
    @nature.destroy

    respond_to do |format|
      format.html { redirect_to admin_organism_period_natures_url(@organism, @period) }
      format.json { head :ok }
    end
  end
  
  protected
  
  def find_income_outcome_books
    @books =  @organism.income_books + @organism.outcome_books
  end


end
