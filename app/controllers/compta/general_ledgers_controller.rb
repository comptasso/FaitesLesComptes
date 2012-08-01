# coding: utf-8

# Classe destinée à afficher une general_ledger des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la general_ledger par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une general_ledger et
# affiche show
#
class Compta::GeneralLedgersController < Compta::ApplicationController


  def new
     @general_ledger = Compta::GeneralLedger.new(period_id:@period.id).with_default_values
  end

  # utile pour afficher la general_ledger en pdf
  def show
    parameters = {period_id:@period.id}.merge(params[:general_ledger])
    @general_ledger = Compta::GeneralLedger.new(parameters )
    if @general_ledger.valid?
      respond_to do |format|
        format.pdf  {send_data @general_ledger.render_pdf,
          filename:"Grand_livre_#{@organism.title}.pdf"} #, disposition:'inline'}
      end
    else
      respond_to do |format|
        format.pdf {redirect_to new_compta_period_general_ledger_url(@period)}
      end
    end
  end

  def create
    parameters = {period_id:@period.id}.merge(params[:compta_general_ledger])
    @general_ledger = Compta::GeneralLedger.new(parameters)
    if @general_ledger.valid?
      respond_to do |format|
        format.html { redirect_to  compta_period_general_ledger_url(@period, :general_ledger=>params[:compta_general_ledger], :format=>'pdf')}
        format.js
      end
    else
      respond_to do |format|
        format.html { render 'new'}
        format.js {render 'new'}
      end

  end
  end




end
