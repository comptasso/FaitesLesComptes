# -*- encoding : utf-8 -*-

class Compta::AccountsController < Compta::ApplicationController
  # GET /compta/accounts
  # GET /compta/accounts.json
  # index affiche le plan comptable pour l'exercice
  def index
    @compta_accounts = @period.accounts

    respond_to do |format|
      format.html # index.html.erb
      format.pdf {send_data Account.to_pdf(@period).render, filename:'Plan_comptable.pdf'} #, disposition:'inline'}
      format.json { render json: @compta_accounts }
    end
  end

 
end
