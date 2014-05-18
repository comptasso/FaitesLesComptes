  
  
module Importer
    
  # Classe destinée à importer des lignes de relevés de comptes
  # à partir de fichier fournis par les banques.
  # 
  # Cette classe utilise ensuite les ofx_reader et csv_reader pour 
  # lire effectivement les fichiers
  #  
  #   
  # 
  class BaseImporter
    include ActiveModel::Validations # pour avoir errors.add
    
    attr_reader :file, :ba_id
    
    def initialize(file, ba_id)
      @file = file
      @ba_id = ba_id
    end
    
    
      
    def load_imported_rows
      raise "Cette méthode doit être implémentée dans les classes filles"
    end     
    
    protected 
    # guess_date tente de lire la date et sinon ajoute une erreur au modèle
    # guess_date retourne toujours une date, soit la bonne, soit la date du jour.
    def guess_date(str, index)
      str.to_date
    rescue
      errors.add(:base, "Erreur de date à la ligne #{index}")
      Date.today
    end
      
    # méthode qui permet d'éliminer les lignes dont tous les champs sont nil
    def not_empty?(row)
      row.fields.map(&:blank?).include?(false)
    end
      
    # Corrige la narration en retirant les retours à la ligne et en limitant
    # le nombre de caractères.  
    #
    def correct_narration(text)
      text.gsub("\n",'- ').gsub(/\s+/, ' ').strip.
        truncate(MEDIUM_NAME_LENGTH_MAX). # on tronque
      gsub(/\s+\-$/, '')# on retire le - final au cas où le troncate tombe 
         
    end 
      
      
      
      
      
  end
    
end
  
  
