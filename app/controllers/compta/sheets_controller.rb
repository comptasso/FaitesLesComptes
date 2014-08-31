# coding: utf-8

# Controller permettant d'afficher les différentes pages de restitution des comptes
# actif, passif, ...
# la vue index prende une collection en paramètres et peut ainsi afficher un
# bilan (actif et passif), un compte de résultats (exploitation, financier, exceptionnel)
# mais aussi sert de vue (show) en n'appelant qu'un seul élémnent (actif par exemple)

#load "#{Rails.root}/lib/pdf_document/pdf_rubriks.rb"
#
#load "#{Rails.root}/lib/pdf_document/pdf_sheet.rb"
#load "#{Rails.root}/lib/pdf_document/pdf_detailed_sheet.rb"

require 'pdf_document/base'

class Compta::SheetsController < Compta::ApplicationController
  
  include Pdf::Controller # apporte les méthodes pour les delayed_export_jobs
  
  before_filter :check_nomenclature, :only=>[:index, :show]
  before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]

  def index
    # @docs est une collection de Compta::Sheet
    @docs = params[:collection].map do |c|
      # TODO mettre cela dans le modèle
      fol = @nomenclature.folios.find_by_name(c.to_s)
      @nomenclature.sheet(@period, fol)
    end
    
    respond_to do |format|
      send_export_token # pour gérer le spinner lors de la préparation du document
      format.html 
      format.csv {
        
        datas = ''
        @docs.each {|doc| datas += doc.to_index_csv } 
        send_data datas, :filename=>export_filename(@docs, :csv, params[:title])
      }
      format.xls {
        
        datas = ''
        @docs.each {|doc| datas += doc.to_index_xls}
        send_data datas, :filename=>export_filename(@docs, :csv, params[:title])
      }

    end
  end
  
  # l'action show montre la construction de la sheet en détaillant pour chaque rubrique
  # les comptes qui ont contribué au calcul. 
  # 
  # La variable d'instance @rubriks est donc constituée ici de rubriks et de rubrik_lines
  #
  def show
    folio = @nomenclature.folios.find(params[:id])
    @sheet = @nomenclature.sheet(@period, folio)
    
    if @sheet && @sheet.valid?

      respond_to do |format|
        send_export_token # pour gérer le spinner lors de la préparation du document
        format.html {@rubriks = @sheet.fetch_lines}
        format.csv { send_data @sheet.to_csv, filename:export_filename(folio, :csv) } 
        format.xls { send_data @sheet.to_xls, filename:export_filename(folio, :csv) }
        #        format.pdf do
        #          pdf = @sheet.to_detailed_pdf
        #          send_data pdf.render, filename:export_filename(pdf, :pdf)
        #        end
      end
    else
      flash[:alert] = "Le document demandé n'a pas été trouvé " unless @sheet
      flash[:alert] = "Le document demandé comporte des erreurs : #{@sheet.errors.full_messages.join('; ')}"
      redirect_to compta_nomenclature_url # affiche la liste des folios de la nomenclature
      # TODO gagnerait éventuellement à être un folios_controller et une vue index
    end
  end

  # bilans est une action accessoire qui renvoie vers index avec actif et passif comme 
  # paramètres de collection
  def bilans
    redirect_to compta_sheets_url(:collection=>[:actif, :passif], :title=>'Bilan')
  end

  # resultats renvoie vers index avec exploitation, financier et exceptionnel
  def resultats
    redirect_to compta_sheets_url(:collection=>@organism.nomenclature.resultats.collect(&:name),
      :title=>'Comptes de Résultats')
  end

  def liasse
    redirect_to compta_sheets_url(:collection=>@organism.nomenclature.folios.collect(&:name),
      :title=>'Liasse complète')
  end

  # pluriel volontaire pour le distinguer de show/benvolat qui montre le détail de la page benevolat
  # tandis qu'ici on veut l'action index, mais avec une collection d'un seul élément
  # ce qui perturbe le routage
  # Ici avec sheets/benevolats, on est bien différent de sheets/benevolat qui est routée sur show
  def benevolats
    redirect_to compta_sheets_url(:collection=>[:benevolat], :title=>'Bénévolat')
  end


  

  protected

  # appelé par before_filter pour s'assurer que la nomenclature est valide
  # TODO la logique devrait être de rendre cette persistence dans le modèle 
  # Nomenclature
  def check_nomenclature
    @nomenclature = @organism.nomenclature
    if !@period.nomenclature_ok
      flash[:alert] = collect_errors(@nomenclature) unless @nomenclature.coherent?
    end
  end 
  
  # créé les variables d'instance attendues par le module PdfController
  def set_exporter
    @exporter = @period
  end
  
  # création du job et insertion dans la queue
  # on utilise le params :collection pour savoir si on est dans la publication d'une 
  # collection (une action primitive :index) ou un show.
  # Car comme l'action est chaque fois produce_pdf, il faut un autre moyen de 
  # différentier les deux. 
  def enqueue(pdf_export)
    if params[:collection] 
      Delayed::Job.enqueue Jobs::SheetsPdfFiller.new(@organism.database_name, pdf_export.id, {period_id:@period.id, collection:params[:collection]})
    else # cas de l'action show
      Delayed::Job.enqueue Jobs::SheetPdfFiller.new(@organism.database_name, pdf_export.id, {period_id:@period.id, folio_id:params[:id]})
    end
  end
  
  
  
 

end

