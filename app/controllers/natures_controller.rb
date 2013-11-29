# -*- encoding : utf-8 -*-

class NaturesController < ApplicationController 

  def stats
    @filter=params[:destination].to_i || 0
    @filter_name = Destination.find(@filter).name if @filter != 0
    @sn = Stats::StatsNatures.new(@period, @filter)
    send_export_token

    respond_to do |format| 
      format.html
      format.pdf {
        pdf = @sn.to_pdf 
        send_data @sn.to_pdf.render, filename:export_filename(pdf, :pdf)
        }
      format.csv { send_data @sn.to_csv, filename:export_filename(@snf, :csv, 'Statistiques par nature')  }  
      format.xls { send_data @sn.to_xls, filename:export_filename(@snf, :csv, 'Statistiques par nature')  }
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
  end
  
  protected
  
  def set_filter
    @filter = params[:destination].to_i || 0
    @filter_name = Destination.find(@filter).name if @filter != 0
  end
  

end
