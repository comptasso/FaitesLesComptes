# -*- encoding : utf-8 -*-

class NaturesController < ApplicationController

  def stats
    @filter=params[:destination].to_i || 0
    @recettes=@period.natures.recettes
    @depenses=@period.natures.depenses
    @total_recettes=@period.stat_income_year(@filter)
    @total_depenses=@period.stat_outcome_year(@filter)
  end


 
 
end
