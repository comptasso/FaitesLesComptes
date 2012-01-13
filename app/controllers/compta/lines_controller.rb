# coding: utf-8


class Compta::LinesController < Compta::ApplicationController

  before_filter :find_account

  # GET /compta/accounts
  # GET /compta/accounts.json
  def index
    @lines = @account.lines.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @compta_accounts }
    end
  end

 
  private

  def find_account
    @account=Account.find(params[:account_id])
  end


end
