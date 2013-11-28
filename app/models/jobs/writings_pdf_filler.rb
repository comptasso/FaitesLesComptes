module Jobs
  
  class WritingsPdfFiller < Struct.new(:db_name, :export_pdf_id, :options)
    
    def before(job)
      Rails.logger.debug 'Dans before job de Jobs::WritingsPdfFiller'
      Apartment::Database.process(db_name) do
        # trouve le exportable 
        @export_pdf = ExportPdf.find(export_pdf_id)
        @export_pdf.update_attribute(:status, 'processing')
        @book = @export_pdf.exportable
        @period = Period.find(options[:period_id])
        
        if options[:mois] == 'tous'
          @monthly_extract = Extract::InOut.new(@book, @period)
        else
          @monthly_extract = Extract::MonthlyInOut.new(@book, year:options[:an], month:options[:mois])
        end
      end
    end
    
    
    # doit se connecter à la base de données pour récupérer 
    # le record export_pdf. Puis celui-ci donne le document, ce qui permet de 
    # construire l'extrait demandé. 
    # Voir s'il ne faudra pas les spécialiser
    def perform
        Apartment::Database.process(db_name) do
          Rails.logger.debug 'Processing pdf rendering by Jobs::WritingsPdfFiller'
          @export_pdf.content = @monthly_extract.to_pdf.render
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