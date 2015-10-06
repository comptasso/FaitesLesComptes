# -*- encoding : utf-8 -*-

# CashLines est un controller spécialisé pour afficher les lignes qui relèvent
# d'écritures ayant mouvementé une caisse.
#
# Elle hérite de InOutWritingsController car en fait c'est la même logique
# Book devient simplement ici un livre de caisse, lequel est virtuel.
#
# Les before_filter find_book et fill_mois sont une surcharge de ceux définis dans
# in_out_writings_controller
#
# TODO : on devrait vérifier que les autres actions de ce controller ne sont
# pas accessibles.
#
class CashLinesController < InOutWritingsController

  # surcharge de Index
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
      # TODO ligne à supprimer puisqu'on utilise le delayed jobs
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
    @pdf_file_title = "Livre de caisse : #{@cash.name}"
  end

  # création du job et insertion dans la queue
  def enqueue(pdf_export)
    Delayed::Job.enqueue Jobs::VirtualCashPdfFiller.new(Tenant.current_tenant.id,
      pdf_export.id, {period_id:@period.id, mois:params[:mois], an:params[:an]})
  end



end
