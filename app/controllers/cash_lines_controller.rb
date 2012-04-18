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
    @monthly_extract = Utilities::MonthlyCashExtract.new(@book, @date)
    # FIXME remplacer fill_soldes par qqc qui ressemble à MonthlyBookExtract

    respond_to do |format|
      format.html {render 'cash_lines/index'}
      format.json { render json: @lines }
    end
  end

  private

  def find_book
    @book=Cash.find(params[:cash_id])
    @organism=@book.organism
  end

  def fill_mois
    if params[:mois]
      @mois = params[:mois]
    else
      @mois= @period.guess_month
     redirect_to cash_cash_lines_url(@book, mois: @mois) if (params[:action]=='index')
    end
  end

end
