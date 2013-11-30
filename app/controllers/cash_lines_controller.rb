# -*- encoding : utf-8 -*-


# CashLines est un controller spécialisé pour afficher les lignes qui relèvent
# d'une écriture attachée à une caisse.
#
# Elle hérite de LinesController car en fait c'est la même logique
# Book devient simplement ici un livre de caisse, lequel est virtuel.
#
# Les before_filter find_book et fill_mois sont une surcharge de ceux définis dans
# lines_controller
#
class CashLinesController < InOutWritingsController
  include Pdf::Controller
  
  before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]

# la méthode index est héritée de InOutWritingsController
  def index
    if params[:mois] == 'tous'
      @monthly_extract = Extract::Cash.new(@cash, @period)
    else
      @monthly_extract = Extract::MonthlyCash.new(@cash, {year:params[:an], month:params[:mois]})
    end
    send_export_token # envoie un token pour l'affichage du message Juste un instant 
    # pour les exports
    respond_to do |format|
      format.html
      format.pdf do
        pdf = @monthly_extract.to_pdf
        send_data pdf.render, :filename=>export_filename(pdf, :pdf)
      end       
      format.csv { send_data @monthly_extract.to_csv, filename:export_filename(@monthly_extract, :csv)  }  # pour éviter le problème des virgules
      format.xls { send_data @monthly_extract.to_xls, filename:export_filename(@monthly_extract, :csv)  }
    end
   end

  private

  # find_book qui est défini dans LinesController est surchargée pour chercher un Cash
  def find_book
    @cash = Cash.find(params[:cash_id])
  end
  
  # créé les variables d'instance attendues par le module PdfController
  def set_exporter
    @exporter = @cash
  end
  
  # création du job et insertion dans la queue
  def enqueue(pdf_export)
    Delayed::Job.enqueue Jobs::VirtualCashPdfFiller.new(@organism.database_name, pdf_export.id, {period_id:@period.id, mois:params[:mois], an:params[:an]})
  end

  

end
