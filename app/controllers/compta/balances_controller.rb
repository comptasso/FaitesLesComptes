# coding: utf-8

class Compta::BalancesController < Compta::ApplicationController

  before_filter :fill_dates
  
  def show
    @balance=Compta::Balance.new(@period, @accounts, @begin_date, @start_date)
  end
  
  def new   
      
  end
  
  def create
    @balance=Compta::Balance.new(@period, @accounts, @begin_date, @start_date)
    render 'show'
  end
  
  private
  
  def fill_dates
    @begin_date=picker_to_date(params[:begin_date]) || @period.start_date
    @end_date=picker_to_date(params[:end_date]) || @period.close_date
    if (params[:begin_account] && params[:end_account])
      params[:begin_account],params[:end_account] = params[:end_account], params[:begin_account] if params[:end_account] < params[:begin_account]
      @accounts=@period.accounts.order('number ASC').where(:number =>params[:begin_account]..params[:end_account])

    else
      @accounts=@period.accounts.order('number ASC')
    end

    @begin_account=@accounts.all.first
    @end_account=@accounts.all.last
  end
end
