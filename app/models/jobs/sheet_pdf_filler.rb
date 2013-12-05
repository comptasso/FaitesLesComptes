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
  # L'utilisation se fait dans le controller (voir natures_controller)
  # Delayed::Job.enqueue Jobs::WritingsPdfFiller.new(@organism.database_name, 
  # export_pdf.id, {period_id:@period.id, destination:0})
  #
  # L'argument database_name permet de gérer les jobs dans la schéma Public
  # alors que les enregistrements sont dans les schémas particuliers.
  # Chaque appel de méthode se fait donc par un appel à Apartment::Database.process(dbname) 
  # et un bloc.
  # 
  class SheetPdfFiller < BasePdfFiller
    
    # on surcharge la classe car on ne rend pas to_pdf mais to_detailed_pdf
    # puisque Sheet est destiné à produire une vue détaillée.
    # TODO on pourrait faire une architecture plus propre avec un controller
    # pour les vues détaillées et un pour les collections non détaillées.
    def perform      
      Apartment::Database.process(db_name) do
          @export_pdf.content = @document.to_detailed_pdf.render
          @export_pdf.save
      end
    end
        
    protected
    
    # fournit la variable d'instance document.
    def set_document(options)
        period  = Period.find(options[:period_id])
        nomenclature = period.organism.nomenclature
        folio = nomenclature.folios.find_by_id(options[:folio_id])
        @document = nomenclature.sheet(period, folio)
    end
    
    
    
  end
  
  
end