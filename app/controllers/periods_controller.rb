# -*- encoding : utf-8 -*-


class PeriodsController < ApplicationController


  # change d'exercice sans pour autant afficher l'exercice concerné 
  # utile par exemple quand on veut rester dans les livres en changeant d'exercice
  def change
    logger.info "Dans la méthode change avec params[:id] = #{params[:id]}"
    logger.info "request : #{request.env['HTTP_REFERER']} "
    @period=Period.find(params[:id])
    if @period
      logger.info "Changement d'exercice, nouvel exercice #{@period.exercice}"
      session[:period]=@period.id
      # on traite le cas où l'action comporte une référence à an et mois
      # le changement d'exercice doit donc modifier ces paramètres
      if request.env["HTTP_REFERER"] =~ /an=\d{4}&mois=(\d{2})/
        mois = $1
        # on vérifie que le mois demandé ait du sens pour l'exercice concerné
        # Est-ce que le mois appartient à l'exercice ?
        logger.info "paramètres trouvés mois : #{mois}"
        if @period.include_month?(mois)
          Rails.logger.info "include_month a renvoyé true pour #{mois}"
          my = @period.find_first_month(mois)
        else
          logger.info "include_month n'a pas renvoyé true pour #{mois}"
          flash[:alert] = 'Le mois demandé n\'existe pas pour cet exercice, affichage d\'un autre mois'
          my = @period.guess_month
        end
        logger.info "nouveau paramètres #{my.year} #{my.month}"
        r = request.env['HTTP_REFERER']
        r.sub!(/an=(\d{4})/, "an=#{my.year}")
        redirect_to r and return
      end
      # redirect_to :back est adapté pour toutes les autres actions qui ne déclanchent pas un
      # affichage de livres ou de statistiques.
      redirect_to :back 
     else
      logger.warn 'Change period n a pas pu trouver un exercice (dans periods_controller#change)'
      redirect_to admin_organisms_url
    end
  end
end
