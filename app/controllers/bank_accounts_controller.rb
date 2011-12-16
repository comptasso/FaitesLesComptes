# -*- encoding : utf-8 -*-

class BankAccountsController < ApplicationController

  before_filter :find_organism, :current_period

  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = @organism.bank_accounts.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bank_accounts }
    end
  end

  # GET /bank_accounts/1
  # GET /bank_accounts/1.json
  def show
    @bank_account = BankAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bank_account }
    end
  end

  # GET /bank_accounts/new
  # GET /bank_accounts/new.json
  def new
    @bank_account = @organism.bank_accounts.new
    @bank_account.opened_at = Date.today
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bank_account }
    end
  end

  # GET /bank_accounts/1/edit
  def edit
    @bank_account = BankAccount.find(params[:id])
    @bank_account.opened_at ||= Date.today
  end

  # POST /bank_accounts
  # POST /bank_accounts.json
  def create
    params[:bank_account][:opened_at]= picker_to_date(params[:pick_date_opened_at])
    @bank_account = @organism.bank_accounts.new(params[:bank_account])

    respond_to do |format|
      if @bank_account.save
        format.html { redirect_to organism_bank_accounts_url(@organism), notice: 'Le compte bancaire a été créé.' }
        format.json { render json: @bank_account, status: :created, location: @bank_account }
      else
        format.html { render action: "new" }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bank_accounts/1
  # PUT /bank_accounts/1.json
  def update
    params[:bank_account][:opened_at]= picker_to_date(params[:pick_date_opened_at])
    @bank_account = BankAccount.find(params[:id])

    respond_to do |format|
      if @bank_account.update_attributes(params[:bank_account])
        format.html { redirect_to organism_bank_accounts_url(@organism), notice: 'Le compte bancaire a été mis à jour.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_accounts/1
  # DELETE /bank_accounts/1.json
  def destroy
    @bank_account = BankAccount.find(params[:id])
    @bank_account.destroy

    respond_to do |format|
      format.html { redirect_to organism_bank_accounts_url(@organism) }
      format.json { head :ok }
    end
  end
end
