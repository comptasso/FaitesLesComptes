class CashControlsController < ApplicationController
  def index
  end

  def show
  end

  def new

    @cash=@organism.cashes.find(params[:cash_id])
    @previous_cash_control=@cash.cash_controls.last(:order=>'date ASC')
    @cash_control=@cash.cash_controls.new(:date=>Date.today)
  end

  def create
     params[:cash_control][:date]= picker_to_date(params[:pick_date_at])
    @cash=@organism.cashes.find(params[:cash_id])
    @cash_control=@cash.cash_controls.new(params[:cash_control])
    if @cash_control.save
      redirect_to organism_url(@organism)
    else
      render :new
    end
  end

  def update

  end

  def edit
  end

end
