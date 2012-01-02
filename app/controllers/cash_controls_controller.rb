# -*- encoding : utf-8 -*-

class CashControlsController < ApplicationController
  def index
    @cash=@organism.cashes.find(params[:cash_id])
    @cash_controls=@cash.cash_controls.for_period(@period)
  end

  def show
  end

  def new
    @cash=@organism.cashes.find(params[:cash_id])
    @previous_cash_control=@cash.cash_controls.last(:order=>'date ASC')
    @min_date=@organism.find_period.start_date
    @min_date = @previous_cash_control.date unless @previous_cash_control.nil?
    @cash_control=@cash.cash_controls.new(:date=>Date.today)
  end

  def create
    params[:cash_control][:date]= picker_to_date(params[:pick_date_at])
    @cash=@organism.cashes.find(params[:cash_id])
    @cash_control=@cash.cash_controls.new(params[:cash_control])
    if @cash_control.save
      redirect_to organism_cash_cash_controls_url(@organism, @cash)
    else
      render :new
    end
  end

  def update
params[:cash_control][:date]= picker_to_date(params[:pick_date_at])
 @cash=@organism.cashes.find(params[:cash_id])
    @cash_control=@cash.cash_controls.find(params[:id])
     if @cash_control.update_attributes(params[:cash_control])
      redirect_to organism_cash_cash_controls_url(@organism, @cash)
    else
      render :edit
    end
  end

  def edit
    @cash=@organism.cashes.find(params[:cash_id])
    @cash_control=@cash.cash_controls.find(params[:id])
  end

  # lock permet de verrouiller un controle de caisse, 
  # ce qui a pour effet (par un after_update) de verrouiller les lignes qui le concernent
  def lock
    @cash=@organism.cashes.find(params[:cash_id])
    @cash_control=@cash.cash_controls.find(params[:id])
    if @cash_control.update_attribute(:locked, true)
      flash[:notice]= 'Le contrôle a été verrouillé ainsi que les lignes correspondantes'

    else
      flash[:alert] = "Une erreur s'est produite et n'a pas permis de verrouiller le contrôle de caisse"
    end
    redirect_to organism_cash_cash_controls_url(@organism, @cash)
    
  end



end
