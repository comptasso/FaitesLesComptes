# coding: utf-8


class Compta::LinesController < Compta::ApplicationController

  # GET /compta/accounts
  # GET /compta/accounts.json
  def index
    @account=Account.find(params[:account_id])
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    @lines = @account.lines.range_date(@from_date, @to_date)
    fill_soldes
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @compta_accounts }
    end
  end
 
  private

  def fill_soldes
    @solde_debit_avant=@account.lines.solde_debit_avant(@from_date)
    @solde_credit_avant=@account.lines.solde_credit_avant(@from_date)
    @total_debit=@lines.sum(&:debit)
    @total_credit=@lines.sum(&:credit)
    @solde= @solde_credit_avant+@total_credit-@solde_debit_avant-@total_debit
  end



end
