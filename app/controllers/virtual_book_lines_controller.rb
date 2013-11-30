# TODO actuellement, n'est prévu que pour un compte bancaire mais
# pourrait si besoin être utilisé pour une caisse.
# en distinguant si on a un params[cash_id] ou un params[:bank_account_id]

class VirtualBookLinesController < ApplicationController
  include Pdf::Controller
  
  before_filter :find_bank_account, :fill_mois
  before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]
  
  def index
    @virtual_book = @bank_account.virtual_book
    if params[:mois] == 'tous'
      @monthly_extract = Extract::BankAccount.new(@virtual_book, @period)
    else
      @monthly_extract = Extract::MonthlyBankAccount.new(@virtual_book, year:params[:an], month:params[:mois])
    end
    
    
    
    send_export_token # envoie un token pour l'affichage du message Juste un instant 
    # pour les exports
    respond_to do |format|
      format.html
      format.csv { send_data @monthly_extract.to_csv, :filename=>export_filename(@monthly_extract, :csv)   }  # pour éviter le problème des virgules
      format.xls { send_data @monthly_extract.to_xls, :filename=>export_filename(@monthly_extract, :csv)  }
    end
  end
  
  
  
  
  protected
  # on surcharge fill_mois pour gérer le params[:mois] 'tous'
  def fill_mois
    if params[:mois] == 'tous'
      @mois = 'tous'
    else
      super
    end
  end
  
  def find_bank_account
    @bank_account = BankAccount.find(params[:bank_account_id])
  end
  
  # créé les variables d'instance attendues par le module PdfController
  def set_exporter
    @exporter = @bank_account.virtual_book
  end
  
  # création du job et insertion dans la queue
  def enqueue(pdf_export)
    Delayed::Job.enqueue Jobs::VirtualBookPdfFiller.new(@organism.database_name, pdf_export.id, {period_id:@period.id, mois:params[:mois], an:params[:an]})
  end
  
end
