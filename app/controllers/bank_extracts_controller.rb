# -*- encoding : utf-8 -*-

class BankExtractsController < ApplicationController

  before_filter :find_organism, :find_bank_account
before_filter :get_dates, only: [:create, :update]

  # GET /bank_extracts
  # GET /bank_extracts.json
  def index
    @bank_extracts = @bank_account.bank_extracts.all
    if @bank_extracts.size == 0
      redirect_to new_organism_bank_account_bank_extract_url(@organism,@bank_account)
      return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bank_extracts }
    end
  end

  def show
    @bank_extract = BankExtract.find(params[:id])
    @bank_extract_lines=@bank_extract.bank_extract_lines
  end

 def lock
   @bank_extract = BankExtract.find(params[:id])
   # ici on change les attributs false
   @bank_extract.locked=true
   @bank_extract.bank_extract_lines.all.each {|l| l.update_attribute(:locked, true) }

   if @bank_extract.save
     flash[:notice]= "Relévé validé et verrouillé"

   else
     flash[:alert]= "Une erreur n'a pas permis de valider le relevé"
     
   end
     redirect_to book_bank_extract_url(@bank_account,@bank_extract)
 end

  # GET /bank_extracts/new
  # GET /bank_extracts/new.json
  def new

    @bank_extract = @bank_account.bank_extracts.build(begin_sold: @bank_account.last_bank_extract_sold)
    @bank_extract.begin_date= @bank_account.last_bank_extract_day + 1
    @bank_extract.end_date= @bank_extract.begin_date.months_since(1) - 1

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
        format.html { redirect_to organism_bank_account_bank_extract_path(@organism, @bank_account, @bank_extract), notice: "L'extrait de compte a été créé." }
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
        format.html { redirect_to organism_bank_account_bank_extract_path(@organism, @bank_account, @bank_extract), notice: "L'extrait a été modifié " }
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
      format.html { redirect_to book_bank_extracts_url(@bank_account) }
      format.json { head :ok }
    end
  end

  private

  def find_bank_account
    @bank_account=BankAccount.find(params[:bank_account_id])
  end

  def get_dates
    params[:bank_extract][:begin_date]= picker_to_date(params[:pick_date_from])
    params[:bank_extract][:end_date] = picker_to_date(params[:pick_date_to])

  end
end
