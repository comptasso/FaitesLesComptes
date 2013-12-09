# Construit un nouveau Journal Général et l'affiche

class Compta::GeneralLedgersController < Compta::ApplicationController
  include Pdf::Controller
  
  before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]
  
  
  protected
  
  # surcharge de la méthode de Pdf::Controller car il faut fixer la valeur du path
  # pour les autres actions
  def set_request_path
    @request_path = "/compta/periods/#{@period.id}/general_ledger"
  end 

  
  # créé les variables d'instance attendues par le module PdfController
  def set_exporter
    @exporter = @period
    @pdf_file_title = 'Journal Général'
  end
  
  # création du job et insertion dans la queue
  def enqueue(pdf_export)
    Delayed::Job.enqueue Jobs::GeneralLedgerPdfFiller.new(@organism.database_name, pdf_export.id, {period_id:@period.id})
  end
 
  
end
