class Compta::AccountsController < ApplicationController
  # GET /compta/accounts
  # GET /compta/accounts.json
  def index
    @compta_accounts = Compta::Account.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @compta_accounts }
    end
  end

  # GET /compta/accounts/1
  # GET /compta/accounts/1.json
  def show
    @compta_account = Compta::Account.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @compta_account }
    end
  end

  # GET /compta/accounts/new
  # GET /compta/accounts/new.json
  def new
    @compta_account = Compta::Account.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @compta_account }
    end
  end

  # GET /compta/accounts/1/edit
  def edit
    @compta_account = Compta::Account.find(params[:id])
  end

  # POST /compta/accounts
  # POST /compta/accounts.json
  def create
    @compta_account = Compta::Account.new(params[:compta_account])

    respond_to do |format|
      if @compta_account.save
        format.html { redirect_to @compta_account, notice: 'Account was successfully created.' }
        format.json { render json: @compta_account, status: :created, location: @compta_account }
      else
        format.html { render action: "new" }
        format.json { render json: @compta_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /compta/accounts/1
  # PUT /compta/accounts/1.json
  def update
    @compta_account = Compta::Account.find(params[:id])

    respond_to do |format|
      if @compta_account.update_attributes(params[:compta_account])
        format.html { redirect_to @compta_account, notice: 'Account was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @compta_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compta/accounts/1
  # DELETE /compta/accounts/1.json
  def destroy
    @compta_account = Compta::Account.find(params[:id])
    @compta_account.destroy

    respond_to do |format|
      format.html { redirect_to compta_accounts_url }
      format.json { head :ok }
    end
  end
end
