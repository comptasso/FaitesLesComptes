# -*- encoding : utf-8 -*-
class Compta::AccountsController < Compta::ApplicationController
  # GET /compta/accounts
  # GET /compta/accounts.json
  def index
    @compta_accounts = @period.accounts.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @compta_accounts }
    end
  end

  # GET /compta/accounts/1
  # GET /compta/accounts/1.json
  # Compta::AccountsController#show est utilisée pour affichée le listing d'un compte
  def show
    @account=Account.find(params[:id])
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    @lines = @account.lines.range_date(@from_date, @to_date)
    fill_soldes

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @account }
    end
  end

  def new_listing
    @account = Account.find(params[:id])
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    @lines = @account.lines.range_date(@from_date, @to_date)
    fill_soldes
  end

  protected

def fill_soldes
    @solde_debit_avant=@account.lines.solde_debit_avant(@from_date)
    @solde_credit_avant=@account.lines.solde_credit_avant(@from_date)
    @total_debit=@lines.sum(:debit)
    @total_credit=@lines.sum(:credit)
    @solde= @solde_credit_avant+@total_credit-@solde_debit_avant-@total_debit
  end

 
end
