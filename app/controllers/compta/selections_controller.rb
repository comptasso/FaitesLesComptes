class Compta::SelectionsController < Compta::ApplicationController

 def index
    @select_method = params[:scope_condition] == 'unlocked' ? :unlocked : nil
    if @select_method
      @writings = @organism.writings.period(@period).unlocked.
        includes([:book, compta_lines: :account])
    else
      redirect_to :back  
    end
  end

  # POST lock
  # action qui verrouille l'écriture appelée en js
  # on vérifie d'abord qu'on est bien sur une écriture qui peut être
  # verrouillée de cette manière, c'est à dire que l'écriture 
  # relève bien d'un an_book ou d'un od_book, qu'elle n'est pas verrouillée,...
  #
  # Voir les commentaires de Writing#compta_editable?
  def lock
    @writing = Writing.find(params[:id])
    if @writing.compta_editable?
      @writing.lock
    end
  end

  

  
end
