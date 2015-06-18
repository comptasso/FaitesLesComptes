# -*- encoding : utf-8 -*-

# Controller destiné à afficher les statistiques par activités. 
# Il n'y a qu'une seule action qui est index, affichant les lignes d'une 
# instance de la classe Stats::Destinations
# 
# L'export est possible au format csv et xls mais pas en pdf car le nombre 
# de colonnes est non déterminé (Autant de colonnes que d'activités). 
#
class DestinationsController < ApplicationController 
  
  
  before_filter :set_sector  

  def index
    @sd = Stats::Destinations.new(@period, sector:@sector)
    flash.now[:alert] = 'Aucune donnée à afficher' if @sd.lines.empty?

    send_export_token
    respond_to do |format| 
      format.html
#      format.js
      format.csv { send_data @sd.to_csv, filename:export_filename(nil, :csv, 'Statistiques par activités')  }  
      format.xls { send_data @sd.to_xls, filename:export_filename(nil, :csv, 'Statistiques par activités')  }
    end
  end
  
  
  
  protected
  
  def set_sector
    if params[:sector_id]
      @sector = @organism.sectors.find(params[:sector_id])
    else
      @sector = @organism.sectors.first
    end
  end
  


end
