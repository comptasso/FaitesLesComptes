# -*- encoding : utf-8 -*-
class Admin::AccountsController < Admin::ApplicationController
  # GET /compta/accounts
  # GET /compta/accounts.json
  def index
    @accounts = @period.accounts.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @accounts }
    end
  end

  # GET /compta/accounts/new
  # GET /compta/accounts/new.json
  def new
    @account = @period.accounts.new
  end

  # GET /compta/accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # POST /compta/accounts
  # POST /compta/accounts.json
  def create
    @account = @period.accounts.new(params[:account])

    respond_to do |format|
      if @account.save
        # on vérifie la nomenclature et on affiche un message
        nomen = @period.organism.nomenclature
        unless nomen.valid?
          flash[:alert] = nomen.collect_errors
        end
        format.html { redirect_to admin_period_accounts_path(@period), notice: 'Le compte a été créé.' }
        format.json { render json: @account, status: :created, location: @account }
      else
        format.html { render action: "new" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /compta/accounts/1
  # PUT /compta/accounts/1.json
  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to admin_period_accounts_path(@period), notice: 'Le compte a été mis à jour' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compta/accounts/1
  # DELETE /compta/accounts/1.json
  def destroy
    @compta_account = Account.find(params[:id])
    if @compta_account.destroy
      flash[:notice]= "Le compte #{@compta_account.number} - #{@compta_account.title} a été supprimé"
    else
      flash[:error]= "Une erreur s'est produite, le compte #{@compta_account.number} n'a pas pu être supprimé"
    end

    respond_to do |format|
      format.html { redirect_to admin_period_accounts_url(@period) }
      format.json { head :ok }
    end
  end

  

  def mapping
    @accounts=@period.accounts
    @unlinked_natures=@period.natures.without_account
  end

  
end
