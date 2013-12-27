# -*- encoding : utf-8 -*-
class Admin::SubscriptionsController < Admin::ApplicationController
  
  before_filter :limit_year, :complete_masks, :only=>[:new, :edit]
  
  def index
    @subs = @organism.subscriptions
  end
  
  def new
    if @completed.empty?
      flash[:notice] = "Vous n'avez pas de guide de saisie permettant de générer une écriture périodique"
      redirect_to :back
    end
    @subscription = @organism.subscriptions.new
  end
  
  def create
    prepared_params = prepare_params(params[:subscription])
    
    @sub = Subscription.new(prepared_params)
    if @sub.save
      flash[:notice] = "L'écriture périodique '#{@sub.title}' a été créée"
      redirect_to admin_organism_subscriptions_url(@organism)
    else
      render 'new'
    end
  end
  
  def edit
     if @completed.empty?
      flash[:notice] = "Vous n'avez plus de guide de saisie permettant de générer une écriture périodique"
      redirect_to :back
    end
    @subscription = Subscription.find(params[:id])
    unless @subscription
      flash[:alert] = 'Ecriture périodique non trouvée'
      redirect_to admin_organism_subscriptions_url(@organism)
    end
  end
  
  def update
    @subscription = Subscription.find(params[:id])
    prepared_params = prepare_params(params[:subscription])
    if @subscription.update_attributes(prepared_params)
      flash[:notice] = "L'écriture périodique '#{@subscription.title}' a été mise à jour"
      redirect_to admin_organism_subscriptions_url(@organism)
    else
      render 'edit'
    end
    
  end
  
  def destroy
    @sub = Subscription.find(params[:id])
    if @sub && @sub.destroy
      flash[:notice] = "L'écriture périodique '#{@sub.title}' a été supprimée"
    else
      flash[:alert] =  "L'écriture périodique n'a pas été trouvée ou n'a pu être supprimée"
    end
    redirect_to admin_organism_subscriptions_url(@organism)
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
  
  def prepare_params(params)
    if params['permanent'] == 'true'
      params.delete('end_date(1i)'); params.delete('end_date(2i)'); params.delete('end_date(3i)')
    else
      params['end_date(3i)'] = params["day"]
    end
    params.delete('permanent')
    params
  end
  
  
end