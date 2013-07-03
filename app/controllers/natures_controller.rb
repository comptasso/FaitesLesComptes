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
        filename = "#{@organism.title} - Statistiques - #{@period.exercice}"
        filename += " filtrées par #{@filter_name}" if @filter !=0
        filename += '.pdf'
        send_data @sn.to_pdf.render, filename:filename
        }
      format.csv { send_data @sn.to_csv  }  # \t pour éviter le problème des virgules
      format.xls { send_data @sn.to_xls  }
    end
  end

 
 
 
end
