# coding: utf-8
# Classe destinée à afficher une balance des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la balance par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une balance et
# affiche show
#
class Compta::BalancesController < Compta::ApplicationController

  before_filter :fill_dates, :build_balance
  
  def show
    
  end

  def create
    
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

  def build_balance
     @balance=Compta::Balance.new(@period, @accounts, @begin_date, @start_date)
  end
end
