# coding: utf-8
# Classe destinée à afficher une balance des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la balance par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une balance et
# affiche show
#
class Compta::ListingsController < Compta::ApplicationController

  before_filter :default_values

  # show est appelé directement par exemple par les lignes de la balance
  # icon listing qui apparaît à côté des comptes non vides
  def show
   
     @listing = Compta::Listing.new(params[:compta_listing])
     if @listing.valid?
       respond_to do |format|
        format.html {render 'show'}
        format.pdf { send_data @listing.to_pdf.render ,
          filename:"Listing compte #{@listing.account.long_name}.pdf"} #, disposition:'inline'}
        format.csv { send_data @listing.to_csv }  # pour éviter le problème des virgules
        format.xls { send_data @listing.to_xls }
      end
      
     else
      render 'new' # le form new affichera Des erreurs ont été trouvées 
     end
  end

 
  def new
     @listing = Compta::Listing.new(from_date:@period.start_date, to_date:@period.close_date)
     @listing.account_id = params[:account_id] # permet de préremplir le formulaire avec le compte si
     # on vient de l'affichage du plan comptable (accounts#index)
     @accounts = @period.accounts.order('number ASC')
  end

  def create
    
    @listing = Compta::Listing.new(params[:compta_listing])
    if @listing.valid?
       respond_to do |format|
        format.html {render 'show'}
        format.js # vers fichier create.js.erb
        
      end

    else
      respond_to do |format|
        format.html { render 'new'}
        format.js {render 'new'} # vers fichier new.js.erb
      end

  end
  end

  protected

  def default_values
    params[:start_date] ||= @period.start_date
    params[:close_date] ||= @period.close_date
  end

  
 

end
