# -*- encoding : utf-8 -*-

class DestinationsController < ApplicationController 
  
#  include Pdf::Controller
  
  before_filter :set_sector  

  def index
    @sd = Stats::Destinations.new(@period, sector:@sector)
    flash.now[:alert] = 'Aucune donnée à afficher' if @sd.lines.empty?
#    send_export_token

    respond_to do |format| 
      format.html
#      format.js
      format.csv { send_data @sd.to_csv, filename:export_filename(nil, :csv, 'Statistiques par activités')  }  
      format.xls { send_data @sd.to_xls, filename:export_filename(nil, :csv, 'Statistiques par activités')  }
    end
  end
  
  
  
  protected
  
  def set_sector
    @sector = @organism.sectors.find(params[:sector_id]) if params[:sector_id]
  end
  
#  def set_stats_filter 
#    @filter = params[:nature].to_i || 0
#    @filter_name = Nature.find(@filter).name if @filter != 0
#  end
  
  # créé les variables d'instance attendues par le module PdfController
#  def set_exporter
#    @exporter = @period
#    @pdf_file_title = 'Statistiques par activités'
#  end
#  
  # création du job et insertion dans la queue
#  def enqueue(pdf_export)
#    Delayed::Job.enqueue Jobs::StatsDestsPdfFiller.new(@organism.database_name, pdf_export.id, {period_id:@period.id, nature:[@filter]})
#  end
  

end
