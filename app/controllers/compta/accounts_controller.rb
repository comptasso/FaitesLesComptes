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
 


end
