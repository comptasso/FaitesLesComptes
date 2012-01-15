# coding: utf-8

class Compta::PeriodsController < Compta::ApplicationController


  # GET /periods/1
  def show
    @period=Period.find(params[:id])
        session[:period]=@period.id
    redirect_to compta_organism_path(@period.organism)
  end

end
