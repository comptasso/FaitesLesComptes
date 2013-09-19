# -*- encoding : utf-8 -*-

class BankExtractsController < ApplicationController

  before_filter  :find_bank_account
 

  # GET /bank_extracts
  # GET /bank_extracts.json
  def index
    @bank_extracts = @bank_account.bank_extracts.period(@period).all 
    if @bank_extracts.size == 0
      flash[:alert] = 'Pas encore d\'extrait de compte ; Peut-être vouliez vous en saisir un ?'
      redirect_to new_bank_account_bank_extract_url(@bank_account) and return
    end
  end

  
 
  # lock est appelé par le bouton 'valider et verrouillé' de la vue pointage html
  # bouton qui est lui même affiché que lorsque les soldes sont concordants avec les lignes affichées
  # dans le modèle bank_extract, un after save verrouille alors les lignes correspondantes
  def lock
    @bank_extract = BankExtract.find(params[:id])
    @bank_extract.locked = true
    if @bank_extract.save
      flash[:notice]= "Relevé validé et verrouillé"
    else
      flash[:alert]= "Une erreur n'a pas permis de valider le relevé"
    end
    redirect_to bank_extract_bank_extract_lines_url(@bank_extract)
  end

  # GET /bank_extracts/new
  # GET /bank_extracts/new.json
  def new
    @bank_extract = @bank_account.new_bank_extract(@period)
    unless @bank_extract
      flash[:alert] = 'Impossible de créer un nouveau relevé de compte pour cet exercice'
      redirect_to bank_account_bank_extracts_url 
    end

  end

  # GET /bank_extracts/1/edit
  def edit
    @bank_extract = BankExtract.find(params[:id])
  end

  # POST /bank_extracts
  # POST /bank_extracts.json
  def create
    @bank_extract = @bank_account.bank_extracts.new(params[:bank_extract])

    respond_to do |format|
      if @bank_extract.save
        format.html { redirect_to bank_account_bank_extracts_url(@bank_account), notice: "L'extrait de compte a été créé." }
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
        format.html { redirect_to bank_account_bank_extracts_url(@bank_account), notice: "L'extrait a été modifié " }
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
      format.html { redirect_to bank_account_bank_extracts_url(@bank_account) }
      format.json { head :ok }
    end
  end

  private

  def find_bank_account
    @bank_account=BankAccount.find(params[:bank_account_id])
  end

 
end
