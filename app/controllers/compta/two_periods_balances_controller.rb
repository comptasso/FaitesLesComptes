class Compta::TwoPeriodsBalancesController < Compta::ApplicationController

  include Pdf::Controller

  before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]

  def show
      ctpb = Compta::TwoPeriodsBalance.new(@period)
      @detail_lines = ctpb.lines
      respond_to do |format|
      send_export_token # pour gérer le spinner lors de la préparation du document
      format.html
      format.csv { send_data(detail_csv(@detail_lines), filename:export_filename(@detail_lines, :csv, 'Détail des comptes')) }
      format.xls { send_data(detail_xls(@detail_lines), filename:export_filename(@detail_lines, :csv, 'Détail des comptes'))   }
     end
  end

  protected

  def detail_csv(lines)
    CSV.generate({:col_sep=>"\t"}) do |csv|
      csv << ['Numéro', 'Libellé', 'Brut', 'Amortissement', 'Net', 'Ex. précédent']
      lines.each {|l| csv << [l.select_num, l.title, l.brut, l.amortissement, l.net, l.previous_net] }
    end.gsub('.', ',')
  end

  def detail_xls(lines)
    detail_csv(lines).encode("windows-1252")
  end

  # créé les variables d'instance attendues par le module PdfController
  def set_exporter
    @exporter = @period
    @pdf_file_title = 'Détail des comptes'
  end

  # création du job et insertion dans la queue
  def enqueue(pdf_export)
    Delayed::Job.enqueue Jobs::TwoPeriodsBalancePdfFiller.new( Tenant.current_tenant.id,
       pdf_export.id, {period_id:@period.id})
  end



end
