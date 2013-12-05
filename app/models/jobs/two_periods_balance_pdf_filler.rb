module Jobs
  
  # Cette classe est un delayed job qui a pour fonction de préparer le 
  # contenu du fichier pdf pour un livre de recettes ou de dépenses.
  #
  # Les arguments sont 
  # - db_name : la base de données
  # - export_pdf_id : qui est l'id du record export_pdf
  # - options qui est ici seulement un hash avec comme clé period_id
  # 
  # 
  # Voir la classe BasePdfFiller pour plus de détail
  #  
  class TwoPeriodsBalancePdfFiller < BasePdfFiller
        
    protected
    
    # fournit la variable d'instance document.
    def set_document(options)
        period  = Period.find(options[:period_id])
        @document = Compta::TwoPeriodsBalance.new(period)
    end
    
    
    
  end
  
  
end