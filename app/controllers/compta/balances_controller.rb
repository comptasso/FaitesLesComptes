# coding: utf-8

require 'pdf_document/simple.rb'
require 'pdf_document/default.rb'
require 'pdf_document/pdf_balance.rb'

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

    # ce unless est nécessaire pour les cas où l'on change d'exercice
    unless params[:compta_balance]
      redirect_to new_compta_period_balance_url(@period) and return
    end
    @params_balance = params[:compta_balance]
    @balance = Compta::Balance.new({period_id:@period.id}.merge @params_balance)
    if @balance.valid?
      respond_to do |format|
        format.html { render action: 'show'}
        format.js
        format.pdf  {send_data @balance.to_pdf.render('lib/pdf_document/balance.pdf.prawn') ,
          filename:"Balance #{@organism.title}.pdf"} #,  disposition:'inline'}
        format.csv { send_data @balance.to_csv }  # pour éviter le problème des virgules
        format.xlsx { send_data @balance.to_xlsx }
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
