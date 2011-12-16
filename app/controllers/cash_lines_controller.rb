# -*- encoding : utf-8 -*-

# CashLines est un controller spécialisé pour afficher les lignes qui relèvent
# d'une écriture attachée à une caisse
# Elle hérite de LinesController car en fait c'est la même logique
# Book devient simplement ici le livre de caisse
#



class CashLinesController < LinesController

  before_filter :find_book, :current_period, :fill_mois
 

# la méthode index est héritée de LinesController
  def index
  
     fill_soldes

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

  # TODO a modifier pour faire la sélection
  def fill_soldes
   if @period
      @date=@period.start_date.months_since(@mois.to_i)
    else
      @date= Date.today.beginning_of_year.months_since(@mois.to_i)
    end
    @lines = @book.lines.mois(@date).all
    @solde_debit_avant=@book.lines.solde_debit_avant(@date)
    @solde_credit_avant=@book.lines.solde_credit_avant(@date)

    @total_debit=@lines.sum(&:debit)
    @total_credit=@lines.sum(&:credit)
    @solde= @solde_credit_avant+@total_credit-@solde_debit_avant-@total_debit
  end



end
