# coding: utf-8
# Classe destinée à afficher une balance des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la balance par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une balance et
# affiche show
#
class Compta::ListingsController < Compta::ApplicationController

 
  def new
     @listing = Compta::Listing.new(period_id:@period.id, from_date:@period.start_date, to_date:@period.close_date)
     @accounts = @period.accounts.order('number ASC')
  end

  def create

    @listing = Compta::Listing.new({period_id:@period.id}.merge(params[:compta_listing]) )

    if @listing.valid?
      @listing.fill_lines

      render 'show'
    else
      respond_to do |format|
        format.html { render 'new'}
        format.js {render 'new'}
      end
      
  end
  end

  
 

end
