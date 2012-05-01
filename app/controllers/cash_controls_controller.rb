# -*- encoding : utf-8 -*-

class CashControlsController < ApplicationController

  before_filter :find_params, :fill_mois

  def index
    @cash_controls=@cash.cash_controls.mois(@period, params[:mois])
  end

  
  def new
    @previous_cash_control=@cash.cash_controls.for_period(@period).last(:order=>'date ASC')
    @min_date, @max_date = @cash.range_date_for_cash_control(@period)
    @date=[Date.today, @max_date].min
    @cash_control=@cash.cash_controls.new(:date=>@date)
  end

  def create
        @cash_control=@cash.cash_controls.new(params[:cash_control])
    if @cash_control.save
      redirect_to cash_cash_controls_url(@cash, :mois=>@period.guess_month(@cash_control.date))
    else
      @previous_cash_control=@cash.cash_controls.for_period(@period).last(:order=>'date ASC')
      @min_date, @max_date = @cash.range_date_for_cash_control(@period)
      @date=@cash_control.date || [Date.today, @max_date].min
      render :new
    end
  end

  def update
    @cash_control=@cash.cash_controls.find(params[:id])
     if @cash_control.update_attributes(params[:cash_control])
      redirect_to cash_cash_controls_url(@cash, :mois=>@period.guess_month(@cash_control.date))
    else
      @previous_cash_control=@cash.cash_controls.for_period(@period).last(:order=>'date ASC')
      @min_date, @max_date = @cash.range_date_for_cash_control(@period)
      @date=@cash_control.date || [Date.today, @max_date].min
      render :edit
    end
  end

  def edit
    @cash_control=@cash.cash_controls.find(params[:id])
    @min_date, @max_date = @period.start_date, @period.close_date
    @date=@cash_control.date
   end

  # lock permet de verrouiller un controle de caisse, 
  # ce qui a pour effet (par un before_update) de verrouiller les lignes qui le concernent
  def lock
    @cash_control=@cash.cash_controls.find(params[:id])
    if @cash_control.update_attribute(:locked, true)
      flash[:notice]= 'Le contrôle a été verrouillé ainsi que les lignes correspondantes'
    else
      flash[:alert] = "Une erreur s'est produite et n'a pas permis de verrouiller le contrôle de caisse"
    end
    redirect_to cash_cash_controls_url(@cash, :mois=>@period.guess_month(@cash_control.date))
  end


  private

  def find_params
    @cash=Cash.find(params[:cash_id])
    @organism = @cash.organism
    current_period
  end

  def fill_mois
    if params[:mois]
      @mois = params[:mois]
    else
      @mois= @period.guess_month
     redirect_to cash_cash_controls_url(@cash, mois: @mois.to_i) if (params[:action]=='index')
     redirect_to new_cash_cash_control_url(@cash, mois: @mois.to_i) if params[:action]=='new'
    end
  end


end
