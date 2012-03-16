# -*- encoding : utf-8 -*-

class CheckDepositsController < ApplicationController

  # ligne ajoutée pour les tests car sinon ces before_filter qui sont dans application_controller ne sont pas exécutés
  # et du coup des variables comme @organism et @period restent à nil.
  # before_filter :find_organism, :current_period

  before_filter :find_bank_account, except: :new
  before_filter :find_non_deposited_checks
  before_filter :get_pick_date, only: [:create,:update]

  # GET /check_deposits
  def index
    flash[:notice]="Il y a #{@nb_to_pick} chèques à remettre à l'encaissement \
pour un montant de #{sprintf('%0.02f', @total_lines_credit)} €" if @nb_to_pick > 0
    @check_deposits = @bank_account.check_deposits.where(['deposit_date > ? and deposit_date < ?', @period.start_date, @period.close_date]).all
  end
  
  # GET /check_deposits/1
  # GET /check_deposits/1.json
  def show
    @check_deposit = CheckDeposit.find(params[:id]) 
  end

  # GET /check_deposits/new
  # GET /check_deposits/new.json
  def new
    if @nb_to_pick < 1
      redirect_to  bank_account_check_deposits_url(@bank_account), alert: "Il n'y a pas de chèques à remettre"
      return
    end
    @check_deposit = CheckDeposit.new(deposit_date: Date.today)
    if params[:bank_account_id]
      @bank_account=@organism.bank_accounts.find(params[:bank_account_id])
      @check_deposit.bank_account_id = @bank_account.id
    end
    @check_deposit.pick_all_checks # par défaut on remet tous les chèques disponibles
  end


  # GET /check_deposits/1/edit
  def edit
    @check_deposit = CheckDeposit.find(params[:id])
    
  end

  # POST /check_deposits
  # POST /check_deposits.json
  def create
    #  @bank_account a été créé par le before_filter
    @check_deposit = @bank_account.check_deposits.new(params[:check_deposit])
    
    if @check_deposit.save!
     
      redirect_to  organism_bank_account_check_deposits_url, notice: 'La remise de chèques a été créée.'
    else
      render action: "new"
    end
    
  end

  # PUT /check_deposits/1
  # PUT /check_deposits/1.json
  def update
    @check_deposit = CheckDeposit.find(params[:id])
    
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
    redirect_to organism_bank_account_check_deposits_url(@organism, @bank_accounts) 
  end

  private

  def find_bank_account
    bas= @organism.bank_accounts
    @bank_account= bas.find(params[:bank_account_id])
   # @bank_account=@organism.bank_accounts.find(params[:bank_account_id])
  end

  def find_non_deposited_checks
    @lines = CheckDeposit.pending_checks(@organism)
    @total_lines_credit=CheckDeposit.total_to_pick(@organism)
    @nb_to_pick=CheckDeposit.nb_to_pick(@organism)
  end 

  def get_pick_date
    params[:check_deposit][:deposit_date]= picker_to_date(params[:pick_date])
  end
end
