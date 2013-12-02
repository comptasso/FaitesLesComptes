# -*- encoding : utf-8 -*-

# TODO faire les spec de ce controller
# on n'utilise pas de delayed job pour la production du pdf car ce ne doit jamais
# être long.
class Compta::AccountsController < Compta::ApplicationController

  # GET /compta/accounts
  # GET /compta/accounts.json
  # index affiche le plan comptable pour l'exercice
  def index
    @compta_accounts = @period.accounts
    send_export_token
    respond_to do |format|
      
      format.html # index.html.erb
      format.pdf do
        pdf = Account.to_pdf(@period)
        send_data pdf.render, filename:export_filename(pdf, :pdf)
      end
      format.json { render json: @compta_accounts }
    end
  end

 
end
