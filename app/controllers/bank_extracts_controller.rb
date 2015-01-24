# -*- encoding : utf-8 -*-

class BankExtractsController < ApplicationController

  before_filter  :find_bank_account
 

  # GET /bank_extracts
  # GET /bank_extracts.json
  def index
    @bank_extracts = @bank_account.bank_extracts.period(@period).to_a 
  end

  
 
  # lock est appelé par le bouton 'valider et verrouillé' de la vue pointage html
  # bouton qui n'est lui même affiché que lorsque les soldes sont concordants
  # avec les lignes affichées
  # Dans le modèle bank_extract, un after save verrouille alors les lignes correspondantes
  def lock
    @bank_extract = BankExtract.find(params[:id])
    @bank_extract.locked = true
    if @bank_extract.save
      flash[:notice]= "Relevé validé et verrouillé"
    else
      flash.now[:alert]= "Une erreur n'a pas permis de valider le relevé"
    end
    redirect_to bank_extract_bank_extract_lines_url(@bank_extract)
  end

  # GET /bank_extracts/new
  # GET /bank_extracts/new.json
  def new
    @bank_extract = @bank_account.new_bank_extract(@period)
    fill_totals_from_imported_bels if @bank_extract
    unless @bank_extract
      flash[:alert] = 'Impossible de créer un nouveau relevé de compte pour cet exercice'
      redirect_to bank_account_bank_extracts_url 
    end

  end

  # GET /bank_extracts/1/edit
  def edit
    @bank_extract = BankExtract.find(params[:id])
  end
  
  # action permettant d'afficher les lignes d'écriture qui restent à pointer
  # cette action est utilisée lorsque les relevés de compte sont tous pointés
  # pointage redirige vers cette action lorsque c'est le cas.
  # 
  # L'argument permet de n'afficher que les lignes antérieures à la cloture
  # de l'exercice sur lequel on travaille.
  #
  def lines_to_point
    @lines_to_point = @bank_account.not_pointed_lines(@period.close_date)
  end
  

  # POST /bank_extracts
  # POST /bank_extracts.json
  def create
    @bank_extract = @bank_account.bank_extracts.new(bank_extract_params)

    respond_to do |format|
      if @bank_extract.save && @bank_account.imported_bels.empty?
        format.html { redirect_to bank_account_bank_extracts_url(@bank_account), notice: "L'extrait de compte a été créé." }
        format.json { render json: @bank_extract, status: :created, location: @bank_extract }
      elsif @bank_extract.save 
        format.html { redirect_to bank_account_imported_bels_url(@bank_account),
          notice: 'L\'extrait de compte a été créé ; 
Vous pouvez maintenant procéder aux modifications des lignes importées puis générer les écritures'
        }
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
      if @bank_extract.update_attributes(bank_extract_params)
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
  
  # méthode qui tente de remplir les champs total_debit et total_credit avec 
  # les imported_bels en attente
  def fill_totals_from_imported_bels
    ibels = @bank_account.imported_bels.to_a.select {|r| r.date.in? @bank_extract.begin_date..@bank_extract.end_date}
    if ibels.any?
      @bank_extract.total_debit = ibels.sum(&:debit)
      @bank_extract.total_credit = ibels.sum(&:credit)
    end
  end
  
  def bank_extract_params
    params.require(:bank_extract).permit(:bank_account_id, :begin_sold, 
      :total_debit, :total_credit, :begin_date_picker, :end_date_picker)
  end

 
end
