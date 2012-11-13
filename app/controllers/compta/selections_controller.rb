class Compta::SelectionsController < Compta::ApplicationController

  before_filter :selection, :except=>:lock

  def index
    @writings = Writing.period(@period).send(@scope_condition)
  end

  # POST lock
  # action qui verrouille l'écriture appelée en js
  # on vérifie d'abord qu'on est bien sur une écriture qui peut être
  # verrouillée comme celà, ie venant d'un an_book ou d'un od_book
  def lock
    @writing = Writing.find(params[:id])
    if @writing && @writing.book.type.in?(%w(AnBook OdBook))
      @writing.lock
    end
  end

  
  protected


  # ce filtre par sécurité pour qu'on ne puisse pas faire un send avec n'importe quelle méthode
  # on pourra augmenter la liste au fur et à mesure des besoins.
  def selection
    @scope_condition  =  params[:scope_condition]
    logger.debug "condition #{@scope_condition}"
    redirect_to :back unless @scope_condition.in? ['unlocked']
  end

  
end
