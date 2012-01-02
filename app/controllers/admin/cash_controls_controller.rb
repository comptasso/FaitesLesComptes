# -*- encoding : utf-8 -*-

class Admin::CashControlsController < Admin::ApplicationController
  def index
    @cash=@organism.cashes.find(params[:cash_id])
    @cash_controls=@cash.cash_controls.for_period(@period)
  end

    # DELETE /periods/1
  # DELETE /periods/1.json
  def destroy 
    @cash=Cash.find(params[:cash_id])
    @cash_control=CashControl.find(params[:id])
    @cash_control.destroy
    respond_to do |format|
      format.html { redirect_to admin_organism_cash_cash_controls_url(@organism,@cash) }
      format.json { head :ok }
    end
  
  end



end
