# -*- encoding : utf-8 -*-

class CashControlsController < ApplicationController

  before_filter :find_params
  before_filter :fill_mois, only: [:index]
 

  def index
    @cash_controls=@cash.cash_controls.monthyear(MonthYear.new(month:params[:mois], year:params[:an]) )
  end

  
  def new
    @cash_control = @cash.cash_controls.new(:date=>@period.guess_date)
  end

  def create
    @cash_control = @cash.cash_controls.new(cash_control_params)

    if @cash_control.save
      redirect_to cash_cash_controls_url(@cash, @period.guess_month(@cash_control.date).to_french_h)
    else
      @cash_control.date ||= [Date.today, @period.close_date].min
      render :new
    end
  end

  def update
    @cash_control=@cash.cash_controls.find(params[:id])
     if @cash_control.update_attributes(cash_control_params)
      redirect_to cash_cash_controls_url(@cash, @period.guess_month(@cash_control.date).to_french_h)
    else
      @cash_control.date ||= @cash_control.max_date
      render :edit
    end
  end

  def edit
    @cash_control=@cash.cash_controls.find(params[:id])
  end

  def destroy
    @cash_control = @cash.cash_controls.find(params[:id])
    @cash_control.destroy
    redirect_to cash_cash_controls_url(@cash, @period.guess_month(@cash_control.date).to_french_h)
    
  end


  # lock permet de verrouiller un controle de caisse, 
  # ce qui a pour effet (par un before_update) de verrouiller les lignes qui le concernent
  def lock
    @cash_control=@cash.cash_controls.find(params[:id])
    @cash_control.locked = true
    if @cash_control.save
      flash[:notice]= 'Le contrôle a été verrouillé ainsi que les lignes correspondantes'
    else
      flash[:alert] = "Une erreur s'est produite et n'a pas permis de verrouiller le contrôle de caisse"
    end
    monthyear= @period.guess_month(@cash_control.date)
    redirect_to cash_cash_controls_url(@cash, mois:monthyear.month, an:monthyear.year)
  end


  private

  def find_params
    @cash = Cash.find(params[:cash_id])
    @organism = @cash.organism
    current_period
  end
  
  def cash_control_params
    params.require(:cash_control).permit(:date, :amount, :date_picker)
  end


  
end
