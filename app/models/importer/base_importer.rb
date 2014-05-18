  
  
module Importer
    
  # Classe destinée à importer des lignes de relevés de comptes
  # à partir de fichier fournis par les banques.
  # 
  #  Les méthodes #load_imported_rows et #correct doivent être définies dans
  #  les sous classes qui sont actuellement la classe csv et la classe ofx. 
  #  
  #   
  # 
  class BaseImporter 
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
      t = f.split('.')
      t.size > 1 ? t.last : ''
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
      
      
    def bank_account
      @bank_account ||= BankAccount.find(bank_account_id)
    end
      
    def imported_rows
      @imported_rows ||= load_imported_rows
    end
      
  
      
    protected
      
    def load_imported_rows
      raise "Cette méthode doit être implémentée dans les classes filles"
    end     
    
      
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
  
  
