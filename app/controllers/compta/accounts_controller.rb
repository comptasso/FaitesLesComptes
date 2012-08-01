# -*- encoding : utf-8 -*-
class Compta::AccountsController < Compta::ApplicationController
  # GET /compta/accounts
  # GET /compta/accounts.json
  def index
    @compta_accounts = @period.accounts.all

    respond_to do |format|
      format.html # index.html.erb
      format.pdf
      format.json { render json: @compta_accounts }
    end
  end

 
end
