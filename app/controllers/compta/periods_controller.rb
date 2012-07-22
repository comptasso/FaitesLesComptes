# coding: utf-8

class Compta::PeriodsController < Compta::ApplicationController


  # GET /periods/1
  def show
    @period=Period.find(params[:id])
    if @period.accountable?
        session[:period]=@period.id
    redirect_to new_compta_period_balance_path(@period)
    else
      flash[:alert] = "Impossible de passer à cet exercice : soit il n'a pas de comptes, soit les natures ne sont pas toutes reliées aux comptes \n
      Aller dans la zone Administration pour créer le plan de compte et le relier aux natures"
      redirect_to :back
    end
  end

 
end
