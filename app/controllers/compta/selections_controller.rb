class Compta::SelectionsController < Compta::ApplicationController

 def index
    method = params[:scope_condition] == 'unlocked' ? :unlocked : nil
    if method
      @writings = Writing.period(@period).send(:unlocked)
    else
      redirect_to :back
    end
  end

  # POST lock
  # action qui verrouille l'écriture appelée en js
  # on vérifie d'abord qu'on est bien sur une écriture qui peut être
  # verrouillée de cette manière, c'est à dire que l'écriture 
  # relève bien d'un an_book ou d'un od_book
  #
  # TODO : il faudrait aussi éliminer les cas où les écritures
  # relèvent des transferts. 
  def lock
    @writing = Writing.find(params[:id])
    if @writing && @writing.book.type.in?(%w(AnBook OdBook))
      @writing.lock
    end
  end

  

  
end
