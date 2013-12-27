# -*- encoding : utf-8 -*-
class Admin::SubscriptionsController < Admin::ApplicationController
  
  before_filter :limit_year, :complete_masks, :only=>[:new, :edit]
  
  def new
    if @completed.empty?
      flash[:notice] = "Vous n'avez pas de guide de saisie permettant de générer une écriture périodique"
      redirect_to :back
    end
    @subscription = @organism.subscriptions.new
  end
  
  def create
    
    @sub = Subscription.new(params[:subscription])
    if @sub.save
      flash[:notice] = "L'écriture périodique '#{@sub.title}' a été créée"
      redirect_to admin_organism_subscriptions_url(@organism)
    else
      render 'new'
    end
  end
  
  protected
  
  def limit_year
    # TODO peut être mettre le plus vieux des abonnements existants
    @begin_year = @organism.periods.opened.order(:start_date).first.start_date.year
    @end_year = Date.today.year + 20
  end
  
  # renvoie la liste des masques complets donc susceptibles d'être acceptés pour 
  # un abonnement
  def complete_masks
    @completed = @organism.masks.select {|m| m.complete?}
  end
  
  
end