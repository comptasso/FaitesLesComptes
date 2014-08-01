# -*- encoding : utf-8 -*-

class Admin::NaturesController < Admin::ApplicationController
  
 


  # GET /natures
  # GET /natures.json
  def index 
    @book = @organism.in_out_books.find(params[:book_id]) rescue @organism.in_out_books.first
    @natures = @book.natures.includes('account').within_period(@period).order(:position)
  end

  # reorder est appelé par le drag and drop de la vue . Les paramètres
  # transmis sont les suivants :
  #
  #  - id :- id of the row that is moved. This information is set in the id attribute of the TR element.
  #  - toPosition : new position where row is dropped. 
  #  This value will be placed in the indexing column of the row.
  #  
  # Plutôt que de faire un render de la table, reorder renvoie ok ou bad_request
  # et laisse javascript mettre à jour la vue, en l'occurence juste réécrire les positions
  # puisque il n'y a que ça de changé.
  def reorder
    @nature = Nature.find(params[:id])
    raise 'Absence de paramètres de position obligatoires' unless params[:toPosition]
    @nature.insert_at(params[:toPosition].to_i)
    head :ok
  rescue
    head :bad_request
  end

 

 
  # GET /natures/new
  # GET /natures/new.json
  def new 
    @books =  @organism.income_books + @organism.outcome_books
    @nature = @period.natures.new
    @nature.book_id = params[:book_id] || @organism.in_out_books.first.id
    @book = @nature.book
  end

  # GET /natures/1/edit
  def edit
    @books =  @organism.income_books + @organism.outcome_books
    @nature = @period.natures.find(params[:id])
    @book = @nature.book
  end

  # POST /natures
  # POST /natures.json
  def create
    @nature = @period.natures.new(params[:nature])

    respond_to do |format|
      if @nature.save
        format.html { redirect_to admin_organism_period_natures_path(@organism, 
            @period, book_id:@nature.book_id), notice: 'La Nature a été créée.' }
        format.json { render json: @nature, status: :created, location: @nature }
      else
        @books =  @organism.income_books + @organism.outcome_books
        @nature.book_id ||= @books.first.id
        @book = @nature.book
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
        format.html { redirect_to admin_organism_period_natures_path(@organism,
            @period, book_id:@nature.book_id), notice: 'Nature a été mise à jour.' }
        format.json { head :ok }
      else
        @books =  @organism.income_books + @organism.outcome_books
        @book = @nature.book
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
      format.html { redirect_to admin_organism_period_natures_url(@organism, @period, book_id:@nature.book_id) }
      format.json { head :ok }
    end
  end
  
 


end
