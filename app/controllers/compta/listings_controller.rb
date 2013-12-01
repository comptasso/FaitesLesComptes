# coding: utf-8
# Classe destinée à afficher une balance des comptes entre deux dates et pour une série de comptes
# La méthode fill_date permet de remplir les dates recherchées et les comptes par défaut
# ou sur la base des paramètres.
# Show affiche ainsi la balance par défaut
# Un formulaire inclus dans la vue permet de faire un post qui aboutit à create, reconstruit une balance et
# affiche show
#
class Compta::ListingsController < Compta::ApplicationController
# TODO spec à faire
  
  include Pdf::Controller
  before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]

  # show est appelé directement par exemple par les lignes de la balance
  # icon listing qui apparaît à côté des comptes non vides
  def show
   
     @listing = Compta::Listing.new(params[:compta_listing])
      send_export_token
     if @listing.valid?
       respond_to do |format|
        
        format.html {render 'show'}
        format.pdf do 
          pdf = @listing.to_pdf
          send_data pdf.render, filename:export_filename(pdf, :pdf) #, disposition:'inline'}
        end
        format.csv { send_data @listing.to_csv, filename:export_filename(@listing, :csv) }  # pour éviter le problème des virgules
        format.xls { send_data @listing.to_xls, filename:export_filename(@listing, :csv) }
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
  
  # créé les variables d'instance attendues par le module PdfController
  def set_exporter
    account = Account.find(params[:compta_listing][:account_id])
    @exporter = account
  end
  
  # création du job et insertion dans la queue
  def enqueue(pdf_export)
    Delayed::Job.enqueue Jobs::ListingPdfFiller.new(@organism.database_name, pdf_export.id, {params_listing:params[:compta_listing]})
  end
 

end
