# coding: utf-8

# Classe destinée à afficher une balance des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la balance par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une balance et
# affiche show
#
class Compta::BalancesController < Compta::ApplicationController 
  # TODO voir à mettre ce include dans les application_controller ?
  #include ActiveModel::MassAssignmentSecurity
  
  before_filter :set_params_balance
  
  def new
    @balance = Compta::Balance.new(period_id:@period.id).with_default_values
  end

  # utile pour afficher la balance en pdf
  def show
    @balance = Compta::Balance.new({period_id:@period.id}.merge @params_balance)
    send_export_token # utile pour les formats csv, xls et pdf
    if @balance.valid?
      respond_to do |format|
     
        format.html  
        format.js
        format.csv { send_data @balance.to_csv, filename:export_filename(@balance, :csv) } 
        format.xls { send_data @balance.to_xls, filename:export_filename(@balance, :csv)}
        format.pdf { send_data @balance.to_pdf, filename:export_filename(@balance, :pdf)}
      end
    else
      redirect_to new_compta_period_balance_url(@period)
    
    end
  end

  def create
    
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

  protected
  
  def set_params_balance
    @params_balance = params[:compta_balance] || {}
  end
  
end
