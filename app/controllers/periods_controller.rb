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

  def previous
    @period=Period.find(params[:id]).previous_period
    session[:period]=@period.id
    redirect_to :back
  end

  def next
    @period=Period.find(params[:id])
    session[:period]=@period.next_period.id if @period.next_period?
    redirect_to :back
  end

  

end
