# -*- encoding : utf-8 -*-

class CheckDepositsController < ApplicationController

  before_filter :find_bank_account    
  
  # GET /check_deposits
  def index
    @nb_to_pick=CheckDeposit.nb_to_pick
    if @nb_to_pick > 0
      @total_lines_credit=CheckDeposit.total_to_pick
      flash.now[:alert] = "Il reste \
#{ActionController::Base.helpers.pluralize @nb_to_pick, 'chèque'} \
à remettre à l'encaissement \
pour un montant de #{virgule @total_lines_credit} €" 
      end
    @check_deposits = @bank_account.check_deposits.
      within_period(@period).order('deposit_date ASC') 
  end
  
  # GET /check_deposits/1
  # GET /check_deposits/1.json
  def show
    @check_deposit = CheckDeposit.find(params[:id])
    @nb_to_pick=CheckDeposit.nb_to_pick
  end

  # GET /check_deposits/new
  # GET /check_deposits/new.json
  def new
    if CheckDeposit.nb_to_pick(@sector) < 1
      redirect_to  :back, alert: "Il n'y a pas de chèque à remettre"
      return
    end
    @check_deposit = @bank_account.check_deposits.new(deposit_date: @period.guess_date)
    @check_deposit.pick_all_checks(@sector) # par défaut on remet tous les chèques disponibles pour cet organisme
  end


  # GET /check_deposits/1/edit
  def edit
    @check_deposit = CheckDeposit.find(params[:id])
    @nb_to_pick=CheckDeposit.nb_to_pick
  end

  # POST /check_deposits
  # POST /check_deposits.json
  def create
    #  @bank_account a été créé par le before_filter
    @check_deposit = @bank_account.check_deposits.new(params[:check_deposit])
    fill_author(@check_deposit)
    if @check_deposit.save     
      redirect_to  organism_bank_account_check_deposits_url,
        notice: "La remise de chèques a été créée ; pièce n° #{@check_deposit.writing_id}"
    else
      render action: "new"
    end
    
  end

  # PUT /check_deposits/1
  # PUT /check_deposits/1.json
  def update
    # ici on n'utilise pas @bank_account.check_deposits car
    # la modification peut avoir pour objet de changer de compte
    @check_deposit = CheckDeposit.find(params[:id])
    fill_author(@check_deposit)
    if @check_deposit.update_attributes(params[:check_deposit])
      redirect_to  organism_bank_account_check_deposits_url, notice: 'La remise de chèque a été modifiée.'
    else
      render action: "edit"
    end
    
  end

  # DELETE /check_deposits/1
  # DELETE /check_deposits/1.json
  def destroy
    @check_deposit = CheckDeposit.find(params[:id])
    @check_deposit.destroy
    redirect_to organism_bank_account_check_deposits_url(@organism, @bank_account)
  end

  private

  
  def find_bank_account
    @bank_account = BankAccount.find(params[:bank_account_id])
    @sector = @bank_account.sector
  end
  
end
