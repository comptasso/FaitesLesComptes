# -*- encoding : utf-8 -*-

class Admin::CashControlsController < Admin::ApplicationController
   before_filter :find_cash, :fill_mois

  def index
    
   @cash_controls=@cash.cash_controls.mois(@period, params[:mois])
  end

    # DELETE /periods/1
  # DELETE /periods/1.json
  def destroy 
    @cash_control=CashControl.find(params[:id])
    @cash_control.destroy
    respond_to do |format|
      format.html { redirect_to admin_organism_cash_cash_controls_url(@organism,@cash) }
      format.json { head :ok }
    end
  
  end

 private

  def find_cash
    @cash=@organism.cashes.find(params[:cash_id])
  end

  def fill_mois
    if params[:mois]
      @mois = params[:mois]
    else
      @mois= @period.guess_month
     redirect_to admin_organism_cash_cash_controls_url(@organism, @cash, mois: @mois) if (params[:action]=='index')

    end
  end


end
