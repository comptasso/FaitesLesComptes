module Jobs

  # classe de base pour remplir les Pdf en arrière plan
  #
  # Cette classe est virtuelle et doit être dérivée.
  # La seule méthode à implémenter dans les classes filles est la méthode
  # set_document qui est appelée avec l'argument options.
  #
  # Au controller de passer les options nécessaires :
  # - db_name : le nom de la base de données (puisqu'on est multitenant)
  # - export_pdf_id : l'id du record qui servira à stocker le content
  # - et options pour avoir les éléments pour la méthode set_document.
  #
  # Le document doit répondre à to_pdf
  #
  # Les méthodes before, perform et success sont demandées par le gem
  # DelayedJobs.
  #
  # Pour tester ces classes, on doit s'assurer que ces méthodes fonctionnent
  # correctement.
  #
  #
  #
  class BasePdfFiller < Struct.new(:db_name, :export_pdf_id, :options)

    def before(job)
      Rails.logger.debug 'Dans before job de Jobs::StatsPdfFiller'
#      Apartment::Database.process(db_name) do
        # trouve le exportable
        @export_pdf = ExportPdf.find(export_pdf_id)
        @export_pdf.update_attribute(:status, 'processing')
        set_document(options)

#      end
    end


    # doit se connecter à la base de données pour récupérer
    # le record export_pdf. Puis celui-ci donne le document, ce qui permet de
    # construire l'extrait demandé.
    # Voir s'il ne faudra pas les spécialiser
    def perform
        Rails.logger.debug 'performing le job'
#        Apartment::Database.process(db_name) do
          Rails.logger.debug @document
          @export_pdf.content = @document.to_pdf.render
          @export_pdf.save
#        end
    end

    def success(job)
#      Apartment::Database.process(db_name) do
          @export_pdf.update_attribute(:status, 'ready')
#        end
    end

    protected


    def set_document(options)
      raise 'doit être implémentée dans les classes filles'
    end
  end

end
