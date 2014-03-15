class WritingMasksController < ApplicationController
  
  def new
    @mask = @organism.masks.find(params[:mask_id])
    # TODO introduire un controle de validité du mask (ceci au cas où une modification
    # serait intervenue (par exemple nature_name rebaptisé)
    if @mask
      @book = @mask.book
      @monthyear= @period.guess_month
      
      fill_natures
      @in_out_writing, @line, @counter_line = @mask.writing_new(@period.guess_date)
      flash[:retour] = request.env["HTTP_REFERER"]
      render 'in_out_writings/new'
    else
      flash[:alert] = 'Le masque de saisie demandé n\a pas été trouvé'
      redirect_to :back and return
    end
  end
  
  protected
  
  def fill_natures
    @natures=@book.natures.within_period(@period)
  end
  
end
