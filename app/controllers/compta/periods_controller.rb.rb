# coding: utf-8

class Compta::OrganismsController < Compta::ApplicationController

  def show
    @period=Period.find(params[:id])
    redirect_to compta_organism_path(@period.organism)
  end
end
