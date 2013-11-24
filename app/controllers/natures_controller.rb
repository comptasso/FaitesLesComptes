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

end
