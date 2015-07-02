  
  
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
      gsub(/\s+\-$/, '')# on retire le - final au cas où le troncate tombe sur
      # -
         
    end
    
    # Construit un nouveau ImportedBel rattaché à la banque dont l'id est fourni,
    # avec la position position et les informations de la ligne row
    def build_ibel(bank_account_id, position, row)
      ibel = ImportedBel.new(bank_account_id:bank_account_id,  
        position:position, 
        date:row[0],
        narration:row[1],
        debit:row[2], credit:row[3])
      ibel.cat_interpreter # on remplit les champs cat
      ibel.payment_mode_interpreter # on tente de remplir le champ mode de paiement
      ibel
    end
      
      
      
      
      
  end
    
end
  
  
