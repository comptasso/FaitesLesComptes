# coding: utf-8


class Compta::LinesController < Compta::ApplicationController

  before_filter :find_account
  before_filter :fill_mois, only: [:index]

  # GET /compta/accounts
  # GET /compta/accounts.json
  def index
    @lines = @account.lines.all
    fill_soldes
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @compta_accounts }
    end
  end

 
  private

  def find_account
    @account=Account.find(params[:account_id])
  end

  def fill_mois
    if params[:mois]
      @mois = params[:mois]
    else
      @mois= @period.guess_month
     redirect_to compta_account_lines_url(@account, mois: @mois) 
    end
  end

  def fill_soldes
    @date=@period.start_date.months_since(@mois.to_i)

    @lines = @account.lines.mois(@date).all
    @solde_debit_avant=@account.lines.solde_debit_avant(@date)
    @solde_credit_avant=@account.lines.solde_credit_avant(@date)

    @total_debit=@lines.sum(&:debit)
    @total_credit=@lines.sum(&:credit)
    @solde= @solde_credit_avant+@total_credit-@solde_debit_avant-@total_debit
  end



end
