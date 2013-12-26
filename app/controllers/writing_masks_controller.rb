class WritingMasksController < ApplicationController
  
  def new
    @mask = @organism.masks.find(params[:mask_id])
    # TODO introduire un controle de validité du mask (ceci au cas où une modification
    # serait intervenur (par exemple nature_name rebaptisé)
    if @mask
      @book = @mask.book
      @monthyear= @period.guess_month
      
      fill_natures
      @in_out_writing, @line, @counter_line = @mask.writing_new(@period.guess_date)
      flash[:retour] = request.env["HTTP_REFERER"]
      render 'in_out_writings/new'
    else
      # TODO ajouter un flash d'explication
      redirect_to :back and return
    end
  end
  
  protected
  
  # TODO ici il faut remplacer cette méthode par une méthode period.natures_for_book(@book) qui choisira les natures qui
  # conviennent à la classe du livre. Voir aussi dans InOutWritingsController
  def fill_natures
    if @book.class.to_s == 'IncomeBook'
      @natures=@period.natures.recettes
    elsif @book.class.to_s == 'OutcomeBook'
      @natures=@period.natures.depenses
    end
  end
end
