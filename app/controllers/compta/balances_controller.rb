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
  include Pdf::Controller

  # attr_accessible :from_date, :to_date, :from_account_id, :to_account_id
  before_filter :set_params_balance
  before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]
 
  def new
    @balance = Compta::Balance.new(period_id:@period.id).with_default_values
  end

  # utile pour afficher la balance en pdf
  def show
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
  
  # créé les variables d'instance attendues par le module PdfController
  def set_exporter
    @exporter = @period
  end
  
  def set_params_balance
    @params_balance = params[:compta_balance] || {}
  end
  
  # création du job et insertion dans la queue
  def enqueue(pdf_export)
    Delayed::Job.enqueue Jobs::BalancePdfFiller.new(@organism.database_name, pdf_export.id, {period_id:@period.id, params_balance:@params_balance})
  end
 

end
