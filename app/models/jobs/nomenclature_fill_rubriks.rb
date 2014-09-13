module Jobs
  
  # class permettant de remplir en arrière plan toutes les données d'un nouvel
  # exercice
  class NomenclatureFillRubriks < Struct.new(:db_name, :period_id)
    
    def before(job)
      Apartment::Database.process(db_name) do
        @period = Period.find(period_id)
        @nomenclature = @period.organism.nomenclature
      end      
    end
    
    def perform
      Apartment::Database.process(db_name) do
        @nomenclature.rubriks.each do |r|
          r.fill_values(@period)
        end 
        
      end
    end
    
    def success(job)
      Apartment::Database.process(db_name) do
        @nomenclature.update_attribute(:job_finished_at, Time.current)
      end
    end
    
  end
  
end