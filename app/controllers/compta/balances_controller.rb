# coding: utf-8

# Classe destinée à afficher une balance des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la balance par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une balance et
# affiche show
#
class Compta::BalancesController < Compta::ApplicationController
  include ActiveModel::MassAssignmentSecurity

  attr_accessible :from_date, :to_date, :from_account_id, :to_account_id
 
  def new
    @balance = Compta::Balance.new(period_id:@period.id).with_default_values
  end

  # utile pour afficher la balance en pdf
  def show
    @params_balance = params[:compta_balance] || {}
    @balance = Compta::Balance.new({period_id:@period.id}.merge @params_balance)
    send_export_token
    if @balance.valid?
      respond_to do |format|
     
        format.html 
        format.js
        format.pdf  do
          pdf = @balance.to_pdf
          send_data pdf.render, filename:export_filename(pdf, :pdf) #,  disposition:'inline'}
        end 
        format.csv { send_data @balance.to_csv, filename:export_filename(@balance, :csv) }  # pour éviter le problème des virgules
        format.xls { send_data @balance.to_xls, filename:export_filename(@balance, :csv)}
      end
    else
      redirect_to new_compta_period_balance_url(@period)
    
    end
  end

  def create
    @params_balance = params[:compta_balance]
    @balance = Compta::Balance.new({period_id:@period.id}.merge @params_balance)
    if @balance.valid?
      respond_to do |format|
        format.html { render action: 'show'}
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
