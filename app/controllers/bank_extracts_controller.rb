# -*- encoding : utf-8 -*-

class BankExtractsController < ApplicationController

  before_filter :find_book_and_organism
before_filter :get_dates, only: [:create, :update]

  # GET /bank_extracts
  # GET /bank_extracts.json
  def index
    @bank_extracts = @book.bank_extracts.all
    if @bank_extracts.size == 0
      redirect_to new_book_bank_extract_url(@book)
      return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bank_extracts }
    end
  end

  def show
    @bank_extract = BankExtract.find(params[:id])
    @lines=@bank_extract.lines
  end

 def lock
   @bank_extract = BankExtract.find(params[:id])
   # ici on change les attributs false
   @bank_extract.locked=true
   @bank_extract.lines.all.each {|l| l.update_attribute(:locked, true) }

   if @bank_extract.save
     flash[:notice]= "Relévé validé et verrouillé"

   else
     flash[:alert]= "Une erreur n'a pas permis de valider le relevé"
     
   end
     redirect_to book_bank_extract_url(@book,@bank_extract)
 end

  # GET /bank_extracts/new
  # GET /bank_extracts/new.json
  def new

    @bank_extract = @book.bank_extracts.build(begin_sold: @book.extract_sold)
    @bank_extract.begin_date= @book.last_bank_extract_day + 1
    @bank_extract.end_date= @bank_extract.begin_date.months_since(1)

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
        format.html { redirect_to book_bank_extracts_path(@book), notice: "L'extrait de compte a été créé." }
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
        format.html { redirect_to book_bank_extracts_path(@book), notice: "L'extrait a été modifié " }
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
      format.html { redirect_to book_bank_extracts_url(@book) }
      format.json { head :ok }
    end
  end

  private

  def find_book_and_organism
    @book=Book.find(params[:book_id])
    @organism=@book.organism
  end

  def get_dates
    params[:bank_extract][:begin_date]= picker_to_date(params[:pick_date_from])
    params[:bank_extract][:end_date] = picker_to_date(params[:pick_date_to])

  end
end
