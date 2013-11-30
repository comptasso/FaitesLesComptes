# -*- encoding : utf-8 -*-

class NaturesController < ApplicationController 
  
  before_filter :set_stats_filter

  # index renvoie la liste des natures mais sous forme de statistiques avec les montants
  # pour chaque mois de l'exercice
  # 
  # filter permet de filtrer les calculs des montants selon la destination.
  # filter est l'id de destination; 0 si pas de filtre
  #
  def index
    @sn = Stats::StatsNatures.new(@period, @filter)
    send_export_token

    respond_to do |format| 
      format.html
      format.csv { send_data @sn.to_csv, filename:export_filename(nil, :csv, 'Statistiques par nature')  }  
      format.xls { send_data @sn.to_xls, filename:export_filename(nil, :csv, 'Statistiques par nature')  }
    end
  end
  
  # voir le wiki  pour cette méthode et les duex suivantes utilisées pour produire 
  # un pdf avec DelayedJob
  def produce_pdf 
    # destruction préalable de l'export s'il existe déja.
    exp = @period.export_pdf
    exp.destroy if exp  
    # création de l'export 
    exp = @period.create_export_pdf(status:'new')
    Delayed::Job.enqueue Jobs::StatsPdfFiller.new(@organism.database_name, exp.id, {period_id:@period.id, destination:@filter})
    render template:'pdf/produce_pdf'
  end
  
  # TODO faire pdf_ready et deliver_pdf
  def pdf_ready
    pdf = @period.export_pdf
    render :text=>"#{pdf.status}"
  end
  
  def deliver_pdf
    pdf = @period.export_pdf
    if pdf.status == 'ready'
      send_data pdf.content, :filename=>export_filename(nil, :pdf, 'Statistiques par nature') 
    else
      render :nothing=>true
    end
  end
  
  protected
  
  def set_stats_filter
    @filter = params[:destination].to_i || 0
    @filter_name = Destination.find(@filter).name if @filter != 0
  end
  

end
