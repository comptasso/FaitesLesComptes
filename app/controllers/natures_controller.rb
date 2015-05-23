# -*- encoding : utf-8 -*-

class NaturesController < ApplicationController 
  
  include Pdf::Controller
  
  before_filter :set_stats_filter  
  before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]

  # index renvoie la liste des natures mais sous forme de statistiques avec les montants
  # pour chaque mois de l'exercice
  # 
  # filter permet de filtrer les calculs des montants selon la destination.
  # filter est l'id de destination; 0 si pas de filtre
  #
  def index
    @sn = Stats::StatsNatures.new(@period, [@filter])
    send_export_token

    respond_to do |format| 
      format.html
      format.js
      format.csv { send_data @sn.to_csv, filename:export_filename(nil, :csv, 'Statistiques par nature')  }  
      format.xls { send_data @sn.to_xls, filename:export_filename(nil, :csv, 'Statistiques par nature')  }
    end
  end
  
  
  
  protected
  
  def set_stats_filter 
    @filter = params[:destination].to_i || 0
    @filter_name = Destination.find(@filter).name if @filter != 0
  end
  
  # créé les variables d'instance attendues par le module PdfController
  def set_exporter
    @exporter = @period
    @pdf_file_title = 'Statistiques par nature'
  end
  
  # création du job et insertion dans la queue
  def enqueue(pdf_export)
    Delayed::Job.enqueue Jobs::StatsPdfFiller.new(@organism.database_name, pdf_export.id, {period_id:@period.id, destination:[@filter]})
  end
  

end
