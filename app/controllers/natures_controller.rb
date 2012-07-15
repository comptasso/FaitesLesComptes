# -*- encoding : utf-8 -*-

class NaturesController < ApplicationController

  def stats
    @filter=params[:destination].to_i || 0
    @sn = Stats::StatsNatures.new(@period, @filter)
  end

 
 
 
end
