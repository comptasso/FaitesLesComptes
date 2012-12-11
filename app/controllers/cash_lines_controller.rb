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
  

# la méthode index est héritée de InOutWritingsController
  def index
    @monthly_extract = Utilities::MonthlyCashExtract.new(@cash, {year:params[:an], month:params[:mois]})
    respond_to do |format|
      format.html
      format.pdf
      format.csv { send_data @monthly_extract.to_csv(col_sep:"\t")  }  # pour éviter le problème des virgules
      format.xls { send_data @monthly_extract.to_xls(col_sep:"\t")  }
    end
   end

  private

  # find_book qui est défini dans LinesController est surchargée pour chercher un Cash
  def find_book
    @cash = Cash.find(params[:cash_id])
  end

  def fill_mois
    if params[:mois] && params[:an]
      @mois = params[:mois]
      @an = params[:an]
      @monthyear = MonthYear.new(month:@mois, year:@an)
    else
      @monthyear = @period.guess_month
      logger.debug "monthyear demandé : #{@monthyear}"
      redirect_to cash_cash_lines_url(@cash, mois:@monthyear.month, an:@monthyear.year, :format=>params[:format]) if (params[:action]=='index')

    end
  end

 

end
