# -*- encoding : utf-8 -*-


class PeriodsController < ApplicationController

# FIXME : dans la vue index : quand un exercice est fermé, l'action cloture ne doit rien proposer

  # GET /periods
  # GET /periods.json
  def index
    @periods = @organism.periods.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @periods }
    end
  end

  # change d'exercice sans pour autant afficher l'exercice concerné mais ne marche pas
  # FIXME
  # utile par exemple quand on veut rester dans les livres en changeant d'exercice
  def change
    Rails.logger.info "Dans la méthode change avec params[:id] = #{params[:id]}"
    @period=Period.find(params[:id])
    session[:period]=@period.id
    redirect_to :back #organism_path(@organism)
  end
end
