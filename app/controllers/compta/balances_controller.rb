# coding: utf-8
# Classe destinée à afficher une balance des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la balance par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une balance et
# affiche show
#
class Compta::BalancesController < Compta::ApplicationController

  
#  def show
#    @balance = Compta::Balance.new({:period_id=>@period.id}.merge(params[:balance]))
#     respond_to do |format|
#      format.html
#      format.json { render json: @lines }
#      format.pdf
#    end
#  end

  def new
     @balance = Compta::Balance.new(:period_id=>@period.id).with_default_values
  end

  def create
    @balance = Compta::Balance.new({:period_id=>@period.id}.merge(params[:balance]))
     render 'show'
  end
  

  
 

end
