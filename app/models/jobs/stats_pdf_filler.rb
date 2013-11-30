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
  class StatsPdfFiller < Struct.new(:db_name, :export_pdf_id, :options)
    
    def before(job)
      Rails.logger.debug 'Dans before job de Jobs::StatsPdfFiller'
      Apartment::Database.process(db_name) do
        # trouve le exportable 
        @export_pdf = ExportPdf.find(export_pdf_id)
        @export_pdf.update_attribute(:status, 'processing')
        
        period  = Period.find(options[:period_id])
        filter = params[:destination].to_i || 0
        @document = Stats::StatsNatures.new(period, filter)
      end
    end
    
    
    # doit se connecter à la base de données pour récupérer 
    # le record export_pdf. Puis celui-ci donne le document, ce qui permet de 
    # construire l'extrait demandé. 
    # Voir s'il ne faudra pas les spécialiser
    def perform
        Apartment::Database.process(db_name) do
          @export_pdf.content = @document.to_pdf.render
          @export_pdf.save
        end
    end
    
    def success(job)
      Apartment::Database.process(db_name) do
          @export_pdf.update_attribute(:status, 'ready')
        end
    end
    
    
  end
  
  
end