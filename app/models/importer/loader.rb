module Importer
    
  # Classe destinée à importer des lignes de relevés de comptes
  # à partir de fichier fournis par les banques.
  # 
  # Cette classe utilise ensuite les ofx_reader et csv_reader pour 
  # lire effectivement les fichiers
  #  
  #   
  # 
  class Loader  
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
 
    attr_accessor :file, :bank_account_id
    attr_reader :file_importer
      
    validates :file, :bank_account_id, presence:true
    validate :file_extension
    
    # TODO mettre une limite sur la taille
      
    def initialize(attributes = {})
      attributes.each { |name, value| send("#{name}=", value) }
    end
      
    # Ce n'est pas un modèle persistant (on n'a jamais donc de vue edit)
    def persisted?
      false
    end
    
    # Il s'agit de sauve les BelsImporter qui ont été chargées par cet importateur
    # pas de faire persister ce modèle.
    def save
      return false unless valid? # fait donc les tests sur l'extension ou la 
      # présence d'un fichier
      imported_rows
      return false if errors.messages[:read]
      # fait les test sur d'éventuelle erreurs ajoutées
      # lors de l'importation des lignes
      if imported_rows.map(&:valid?).all?  
        imported_rows.each(&:save!)
        true
      else
        imported_rows.each_with_index do |bel, index|
          bel.errors.messages.each do |message|
            errors.add :base, "Ligne #{index+1}: #{message[1].join(', ')}" if message[1].any?
          end
        end
        false
      end
    end
    
    def imported_rows
      @imported_rows ||= load_imported_rows 
    end
    
    protected 
    
    
     def extension
      f = file.respond_to?(:tempfile) ? file.original_filename : file
      t = f.split('.') rescue [] # pour traiter le cas où le nom du fichier ne 
      # répond pas correctement
      t.size > 1 ? t.last : ''
    end
    
    
    def choose_importer
      @file_importer ||= case extension
      when 'csv' then Importer::CsvImporter.new(file, bank_account_id)
      when 'ofx' then Importer::OfxImporter.new(file, bank_account_id)
      else
        Importer::BaseImporter.new(file, bank_account_id)
      end
    end
    
    def load_imported_rows
      choose_importer.load_imported_rows
    rescue CSV::MalformedCSVError
      errors.add(:read, 'Impossible de lire le fichier; Fichier mal formé ?')
      Rails.logger.debug 'Dans le rescyre CSV::MalformedCSVError'
      []  # on retourne un tableau de lignes vide
    end
    
    def file_extension
      errors.add(:file, 'Extension doit être csv ou ofx') unless extension.in? ['csv', 'ofx']
    end
    
    
    
  end
end