

module Pdf
  
  # voir le wiki  pour cette méthode et les deux suivantes utilisées pour produire 
  # un pdf avec DelayedJob.
  #
  # Lorsqu'un controller dispose d'une action pdf, on peut inclure ce module,
  # ce qui ajoute les trois actions
  # 
  # Il faut alors définir deux méthodes : 
  # - la première est set_exporter qui indique 
  # l'objet qui sera utiliser pour créer un export_pdf. Cet objet doit donc avoir 
  # une relation has_one :export_pdf pour que cela fonctionne.
  # - la deuxième est enqueue qui a pour fonction de créer le job et de le mettre dans 
  # la file d'attente, par exemple
  # 
  # def enqueue(pdf_export)
  #   Delayed::Job.enqueue Jobs::StatsPdfFiller.new(@organism.database_name, pdf_export.id, {period_id:@period.id, destination:@filter})
  # end
  # 
  # Il faut également définir un before_filter qui va instancier @document,
  # par exemple
  # before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]
  # 
  #  
  module Controller
     
  # TODO voir pour introduire ici le before_filter que je mets dans chacun des controllers
  # et qui est 
  # before_filter :set_exporter, :only=>[:produce_pdf, :pdf_ready, :deliver_pdf]
  
  def produce_pdf 
    raise "Impossible de produire un pdf sans @exporter; Faites une méthode pour définir @exporter" unless @exporter
    # FIXME ce raise crée une erreur dans le spec de natures_controller
    # raise 'Le controller doit répondre à enqueue' unless self.respond_to?('enqueue')
    # destruction préalable de l'export s'il existe déja.
    exp = @exporter.export_pdf
    exp.destroy if exp  
    # création de l'export 
    exp = @exporter.create_export_pdf(status:'new')
    set_request_path
    enqueue(exp)
    respond_to do |format|
      format.js {render 'pdf/produce_pdf', type:'text/javascript'}
    end
  end
  
  # interroge le statut du fichier export_pdf en cours de construction
  # permet au client de savoir si le fichier est prêt
  def pdf_ready
    pdf = @exporter.export_pdf
    render :text=>"#{pdf.status}"
  end
  
  # méthode assurant la livraison du fichier
  def deliver_pdf
    pdf = @exporter.export_pdf
    if pdf.status == 'ready'
      send_data pdf.content, :filename=>export_filename(pdf, :pdf, @pdf_file_title) 
    else
      render :nothing=>true
    end
  end
  
  protected
  
  
  # set request_path decode l'adresse utilisée
  # et s'en ressert ensuite pour construire les adresse pdf_ready et deliver_pdf
  #
  # Lorsque l'on appelle un pdf (par exemple GeneralLedger) d'une page qui n'est pas 
  # déja GeneralLedger (cas par exemple d'un lien dans un menu accessible de plusieurs
  # pages différentes), il faut surcharger la méthode dans le controller.
  def set_request_path
    request.url[/(.*)\/produce_pdf(\?.*)?/]
    @request_path = $1
  end
    
    
  end
  
end