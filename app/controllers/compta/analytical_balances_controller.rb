# coding: utf-8

# Classe destinée à afficher une balance des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la balance par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une balance et
# affiche show
#
class Compta::AnalyticalBalancesController < Compta::ApplicationController 
    
  before_filter :set_params_anabal
  
  def new
    @anabal = Compta::AnalyticalBalance.with_default_values(@period)
  end

  # utile pour afficher la balance en pdf
  def show
    @anabal = Compta::AnalyticalBalance.new({period_id:@period.id}.merge @params_anabal)
    send_export_token # utile pour les formats csv, xls et pdf
    if @anabal.valid?
      respond_to do |format|
     
        format.html  
        format.js
        format.csv { send_data @anabal.to_csv, filename:export_filename(@anabal, :csv) } 
        format.xls { send_data @anabal.to_xls, filename:export_filename(@anabal, :csv)}
        format.pdf { send_data @anabal.to_pdf, filename:export_filename(@anabal, :pdf)}
      end
    else
      redirect_to new_compta_period_balance_url(@period)
    
    end
  end

  def create
    
    @anabal = Compta::AnalyticalBalance.new({period_id:@period.id}.merge @params_anabal)
    if @anabal.valid?
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
  
  def set_params_anabal
    @params_anabal = params[:compta_analytical_balance] || {}
  end
  
end
