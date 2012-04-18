# -*- encoding : utf-8 -*-

# CashLines est un controller spécialisé pour afficher les lignes qui relèvent
# d'une écriture attachée à une caisse
# Elle hérite de LinesController car en fait c'est la même logique
# Book devient simplement ici le livre de caisse
#



class CashLinesController < LinesController

#  before_filter :find_book, :fill_mois
 

# la méthode index est héritée de LinesController
  def index
    @date = @period.guess_date(@mois)
    @monthly_extract = Utilities::MonthlyCashExtract.new(@cash, @date)
    # FIXME remplacer fill_soldes par qqc qui ressemble à MonthlyBookExtract

    respond_to do |format|
      format.html 
      
    end
  end

  private

  def find_book
    @cash=Cash.find(params[:cash_id])
    @organism=@cash.organism
  end

  def fill_mois
    if params[:mois]
      @mois = params[:mois]
    else
      @mois= @period.guess_month
     redirect_to cash_cash_lines_url(@cash, mois: @mois) if (params[:action]=='index')
    end
  end

end
