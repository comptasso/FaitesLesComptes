module Jobs
  
  # Cette classe est un delayed job qui a pour fonction de préparer le 
  # contenu du fichier pdf pour un livre de recettes ou de dépenses.
  #
  # Les arguments sont 
  # - db_name : la base de données
  # - export_pdf_id : qui est l'id du record export_pdf
  # - et des options qui doivent donner l'id de l'exercice (:period_id), 
  #   et :an et :mois qui permettent de savoir quel mois est demandé.
  #   
  # L'utilisation se fait dans le controller (voir in_out_writings_controller)
  # Delayed::Job.enqueue Jobs::WritingsPdfFiller.new(@organism.database_name, 
  # export_pdf.id, {period_id:@period.id, mois:params[:mois], an:params[:an]})
  #
  # L'argument database_name permet de gérer les jobs dans la schéma Public
  # alors que les enregistrements sont dans les schémas particuliers.
  # Chaque appel de méthode se fait donc par un appel à Apartment::Database.process(dbname) 
  # et un bloc.
  # 
  class VirtualCashPdfFiller < BasePdfFiller
    
    protected
    
    # TODO dryifier cette logique qui est exactement la même que dans l'action index
    # du controller (la transférer dans le modèle book)
    def set_document(options)
      @cash = @export_pdf.exportable
      @period = Period.find(options[:period_id])
      
      if options[:mois] == 'tous'
        @document = Extract::Cash.new(@cash, @period)
      else
        @document = Extract::MonthlyCash.new(@cash, year:options[:an], month:options[:mois])
      end
      
    end
    
    
  end
  
  
end