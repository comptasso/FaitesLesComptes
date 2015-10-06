# -*- encoding : utf-8 -*-

# Une seule action show pour ce controller avec l'affichage du dashboard
#
# Le skip_before_filter est là car on peut arriver directement de la liste
# des comptabilités après en avoir supprimé une. Donc sans que organism et
# period soient définis.
class OrganismsController < ApplicationController

  skip_before_action :find_organism, :current_period, only:[:show]

  # GET /organisms/1 test watcher
  # GET /organisms/1.json
  def show
    @current_user = current_user
    organism_has_changed?(@current_user.organisms.find(params[:id]))

    unless @period
      flash[:alert]= 'Vous devez créer au moins un exercice pour cet organisme'
      redirect_to new_admin_organism_period_url(@organism)
      return
    end

    @date = @period.guess_date

    # Construction des éléments des paves graphiques
    # On ne prend pas en compte un éventuel secteur commun, car il n'a
    # pas de livres à proprement parler
    @paves = []
    @organism.sectors.reject {|s| s.name == 'Commun'}.each {|sec| @paves += sec.paves}
    @paves += @organism.cash_books
    @paves += @organism.bank_books

  end

end
