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
    if params[:mois] == 'tous'
      @monthly_extract = Utilities::CashExtract.new(@cash, @period)
    else
      @monthly_extract = Utilities::MonthlyCashExtract.new(@cash, {year:params[:an], month:params[:mois]})
    end
    
    respond_to do |format|
      format.html
      format.pdf {send_data @monthly_extract.to_pdf.render, :filename=>"#{@organism.title}_Caisse_#{@cash.title}.pdf" }
      format.csv { send_data @monthly_extract.to_csv(col_sep:"\t")  }  # pour éviter le problème des virgules
      format.xlsx { send_data @monthly_extract.to_xlsx(col_sep:"\t")  }
    end
   end

  private

  # find_book qui est défini dans LinesController est surchargée pour chercher un Cash
  def find_book
    @cash = Cash.find(params[:cash_id])
  end

  def local_params
    {:cash_id=>@cash.id}
  end


  # check_if_has_changed_period est rendu nécessaire car on peut accéder directement aux lignes d'un exercice
  # à partir du graphe d'accueil et donc via l'action index.
  def check_if_has_changed_period
    # si le month_year demandé ne fait pas partie de l'exercice,
    if !@period.list_months.include?(@monthyear)
      # voit si on peut trouver l'exercice ad hoc
      @new_period = @organism.guess_period(@monthyear.beginning_of_month)
      if @new_period
        flash[:alert]= "Attention, vous avez changé d'exercice !"
        my = @new_period.guess_month(@monthyear.beginning_of_month) # car si les exercices ne sont pas de même durée,
        # on pourrait tomber dans un exercice qui n'existe pas
        session[:period] = @new_period.id
        redirect_to cash_cash_lines_url(@cash, mois:my.month, an:my.year, :format=>params[:format])
      else
        flash[:alert] = "Le mois et l'année demandés ne correspondent à aucun exercice"
        redirect_to :back
      end
    end

  end


 

end
