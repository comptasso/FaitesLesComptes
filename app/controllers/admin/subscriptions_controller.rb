# -*- encoding : utf-8 -*-
class Admin::SubscriptionsController < Admin::ApplicationController
  
  before_filter :limit_year, :complete_masks
  
  def new
    @subscription = @organism.subscriptions.new
  end
  
  protected
  
  def limit_year
    @begin_year = @organism.periods.opened.order(:start_date).first.start_date.year
    @end_year = Date.today.year + 20
  end
  
  # renvoie la liste des masques complets donc susceptibles d'être acceptés pour 
  # un abonnement
  def complete_masks
    @completed = @organism.masks.select {|m| m.complete?}
  end
  
  
end