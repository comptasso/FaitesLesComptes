# Construit un nouveau Journal Général et le transmet sous forme de
# pdf uniquement

class Compta::GeneralLedgersController < Compta::ApplicationController
  include Pdf::Controller

  before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]


  protected

  # surcharge de la méthode de Pdf::Controller le path des actions pdf_ready?
  # et autres ne peut être deviné à partir de la page courante puisque
  # l'action est obtenue par un élément du menu
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
    Delayed::Job.enqueue Jobs::GeneralLedgerPdfFiller.new(
      @tenant.id, pdf_export.id, {period_id:@period.id})
  end


end
