# coding: utf-8
# Classe destinée à afficher un listing d'un compte entre deux dates
# 
# Ce controller peut être sollicité de deux façons. 
# 
# Méthode 1 : par le menu Listing
# ce qui fait qu'on ne connait pas alors le compte. L'action new est lancée et 
# affiche un formulaire permettant de sélectionner les dates et le compte.
# 
# Le même mécanisme est lancé par une vue modale.
# Le chemin est alors periods/id/listing
# 
# Cela renvoie sur poste/create qui crée le listing et le rend à l'aide de la vue show
# (on aurait pu aussi faire un redirect mais ce serait une perte de temps).
# 
# Méthode 2 : Soit par la vue index des comptes ou par une balance.
# Dans ce cas, on connait le compte demandé. Et l'on peut arriver directement
# sur la vue show. Le chemin est alors account/id/listing? 
# 
# Les exports (pdf, xls, csv) se font par la méthode 1.
#  
#
class Compta::ListingsController < Compta::ApplicationController
# TODO faire fonctionner le pdf en arrière plan
  
  include Pdf::Controller
  before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]

  # show est appelé directement par exemple par les lignes de la balance
  #  au mpyen de l'icon listing qui apparaît à côté des comptes non vides
  def show
     @account = @period.accounts.find(params[:account_id])
     @listing = Compta::Listing.new(params[:compta_listing])
     @listing.account_id = @account.id
     
     
     if @listing.valid?
       send_export_token
       respond_to do |format|
        
        format.html {render 'show'}
        # format.pdf n'existe pas car l'action est produce_pdf qui est assuré par le Pdf::Controller
        format.csv { send_data @listing.to_csv, filename:export_filename(@listing, :csv) }  # pour éviter le problème des virgules
        format.xls { send_data @listing.to_xls, filename:export_filename(@listing, :csv) }
      end
      
     else
       flash[:alert] = @listing.errors.messages
      render 'new' # le form new affichera Des erreurs ont été trouvées 
     end
  end

  # permet de créer un Listing à partir du formualaire qui demande un compte
  # GET periods/listing/new
  def new
     @listing = Compta::Listing.new(from_date:@period.start_date, to_date:@period.close_date)
     @listing.account_id = params[:account_id] # permet de préremplir le formulaire avec le compte si
     # on vient de l'affichage du plan comptable (accounts#index)
     @accounts = @period.accounts.order('number ASC')
  end

  
  # POST periods/listing/create
  # on arrive sur cette actions lorsque l'on remplit le formulaire venant de new
  def create
    @listing = Compta::Listing.new(params[:compta_listing])
    @account = @listing.account
    if @listing.valid?
       respond_to do |format|
        format.html {
          
          redirect_to compta_account_listing_url(@account, compta_listing:params[:compta_listing].except(:account_id))
          
          }
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
  
  # créé les variables d'instance attendues par le module PdfController
  def set_exporter
    @account = Account.find(params[:account_id])
    @exporter = @account
    @pdf_file_title = "Listing Cte #{@account.number}"
  end
  
  # création du job et insertion dans la queue
  def enqueue(pdf_export)
    Delayed::Job.enqueue Jobs::ListingPdfFiller.new(@organism.database_name, 
      pdf_export.id, {account_id:@account.id, params_listing:params[:compta_listing]})
  end
 

end
