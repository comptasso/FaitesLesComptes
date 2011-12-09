# -*- encoding : utf-8 -*-

class CheckDepositsController < ApplicationController

  before_filter :find_bank_account_and_organism
  # GET /check_deposits
  # GET /check_deposits.json
  def index
    @check_deposits = @organism.check_deposits.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @check_deposits }
    end
  end

  # GET /check_deposits/1
  # GET /check_deposits/1.json
  def show
    @check_deposit = CheckDeposit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @check_deposit }
    end
  end

  # GET /check_deposits/new
  # GET /check_deposits/new.json
  def new
    @check_deposit = @bank_account.check_deposits.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @check_deposit }
    end
  end

  # GET /check_deposits/1/edit
  def edit
    @check_deposit = CheckDeposit.find(params[:id])
  end

  # POST /check_deposits
  # POST /check_deposits.json
  def create
    @check_deposit = @bank_account.check_deposits.new(params[:check_deposit])

    respond_to do |format|
      if @check_deposit.save
        format.html { redirect_to [@bank_account, @check_deposit], notice: 'La remise de chèques a été créée.' }
        format.json { render json: @check_deposit, status: :created, location: @check_deposit }
      else
        format.html { render action: "new" }
        format.json { render json: @check_deposit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /check_deposits/1
  # PUT /check_deposits/1.json
  def update
    @check_deposit = CheckDeposit.find(params[:id])

    respond_to do |format|
      if @check_deposit.update_attributes(params[:check_deposit])
        format.html { redirect_to  [@bank_account, @check_deposit], notice: 'La remise de chèque a été modifiée.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @check_deposit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /check_deposits/1
  # DELETE /check_deposits/1.json
  def destroy
    @check_deposit = CheckDeposit.find(params[:id])
    @check_deposit.destroy

    respond_to do |format|
      format.html { redirect_to bank_account_check_deposits_url(@bank_accounts) }
      format.json { head :ok }
    end
  end

  private

  def find_bank_account_and_organism
    @bank_account=BankAccount.find(params[:bank_account_id])
    @organism=@bank_account.organism
  end
end
