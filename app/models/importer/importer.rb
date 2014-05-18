module Importer
    
  # Classe destinée à importer des lignes de relevés de comptes
  # à partir de fichier fournis par les banques.
  # 
  # Cette classe utilise ensuite les ofx_reader et csv_reader pour 
  # lire effectivement les fichiers
  #  
  #   
  # 
  class Importer 
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
 
    attr_accessor :file, :bank_account_id
      
    validates :file, :bank_account_id, presence:true
    validates :extension, inclusion:{in:['csv', 'ofx']}
    # TODO mettre une limite sur la taille
      
    def initialize(attributes = {})
      attributes.each { |name, value| send("#{name}=", value) }
    end
      
    # Ce n'est pas un modèle persistant (on n'a jamais donc de vue edit)
    def persisted?
      false
    end
    
    def extension
      f = file.respond_to?(:tempfile) ? file.tempfile : file
      t = f.split('.') rescue [] # pour traiter le cas où le nom du fichier ne 
      # répond pas correctement
      t.size > 1 ? t.last : ''
    
    end
    
    # récupère la banque et le dernier extrait, vérifie si des lignes ont 
    # des dates postérieures au dernier extrait.
    # Si non : retourne false 
    # Si oui, calcule un hash donnant les éléments nécessaires à la construction
    # de l'extrait suivant.
    def need_extract?(period)
      lbe_date = bank_account.bank_extracts.order('end_date ASC').last.end_date rescue (period.start_date) -1
      if imported_rows.sort {|r| r.date}.last.date > lbe_date
        true # il faudrait un extrait
      else
        false # pas besoin d'extrait
      end
    end
    
    # Il s'agit de sauve les BelsImporter qui ont été chargées par cet importateur
    # pas de faire persister ce modèle.
    def save
      return false unless valid?
      if imported_rows.map(&:valid?).all?
        imported_rows.each(&:save!)
        true
      else
        # TODO ici on pourrait mieux gérer les messages pour éviter d'avoir
        # deux messages :debit montant nul, :credit montant nul, mais un seul
        # On pourrait modifier directement les validators pour ajouter une 
        # erreur sur ligne (et peut-être) retirer les autres erreurs. 
        imported_rows.each_with_index do |bel, index|
          bel.errors.messages.each do |message|
            errors.add :base, "Ligne #{index+2}: #{message[1].join(', ')}" if message[1].any?
          end
        end
        false
      end
    end
    
    
    def imported_rows
      @imported_rows ||= load_imported_rows
    end
    
    def load_imported_rows
      case extension
      when 'csv' then Importer::CsvImporter.new(file, bank_account_id).load_imported_rows
      when 'ofx' then Importer::OfxImporter.new(file, bank_account_id).load_imported_rows
      end
    end
    
  end
end