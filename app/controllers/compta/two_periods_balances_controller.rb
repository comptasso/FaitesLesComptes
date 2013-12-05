class Compta::TwoPeriodsBalancesController < Compta::ApplicationController
  
  def show
      ctpb = Compta::TwoPeriodsBalance.new(@period)
      @detail_lines = ctpb.lines
      respond_to do |format|  
      send_export_token # pour gérer le spinner lors de la préparation du document
      format.html
      format.csv { send_data(detail_csv(@detail_lines), filename:export_filename(@detail_lines, :csv, 'Détail des comptes')) } 
      format.xls { send_data(detail_xls(@detail_lines), filename:export_filename(@detail_lines, :csv, 'Détail des comptes'))   }
      format.pdf {
        
        send_data pdf.render, filename:export_filename(pdf, :pdf)
      }
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
  
  
end
