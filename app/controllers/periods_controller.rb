# -*- encoding : utf-8 -*-


class PeriodsController < ApplicationController


  # change d'exercice sans pour autant afficher l'exercice concerné 
  # utile par exemple quand on veut rester dans les livres en changeant d'exercice
  def change
    Rails.logger.info "Dans la méthode change avec params[:id] = #{params[:id]}"
    @period=Period.find(params[:id])
    if @period
      session[:period]=@period.id
      redirect_to :back #organism_path(@organism)
    else
      logger.warn 'Change period n a pas pu trouver un exercice (dans periods_controller#change)'
      redirect_to admin_organisms_url
    end
  end
end
