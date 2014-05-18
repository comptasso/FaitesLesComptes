module Importer
  
  
  
  # utilise le gem smarter_csv
  # Le fichier doit avoir quatre colonnes avec des titres ,
  # reprenant les champs Date, Libellé, Débit et Crédit, dans cet ordre,
  # mais pas forcément ces libellés.
  # 
  class CsvImporter < Importer::BaseImporter  
  
    
 
  
  
    # TODO voir à gérer les options
    # la méthode qui lit réellement le fichier.
    # l'option headers:true indique que la prmeière ligne du fichier contient
    # les headers
    # 
    # enconding transforme ici l'encoding iso-8859-1 en utf-8 (ce qui sera 
    # probablement meilleur pour la base de données
    # 
    # Ceci a été testé avec un fichier venant du Crédit Agricole (mais dont 
    # on a supprimé 7 ou 8 lignes car le fichier transmis contient quelques 
    # lignes d'infos générales avant de passer au données proprement dites.
    #
    def load_imported_rows(options = {headers:true, encoding:'iso-8859-1:utf-8', col_sep:';'})
      lirs = []
      index = 2
      position = 1
      # permet d'avoir à la fois un fichier temporaire comme le prévoit rails
      # ou un nom de fichier (ce qui facilite les tests et essais).
      f = file.respond_to?(:tempfile) ? file.tempfile : file
      begin
        CSV.foreach(f, options) do |row|
          
          # vérification des champs pour les lignes autres que la ligne de titre
          if not_empty?(row) && correct?(row, index)
            
            # création d'un array de Bel
            ibel =  ImportedBel.new(bank_account_id:ba_id, 
              position:position, 
              date:row[0], 
              narration:row[1],
              debit:row[2], credit:row[3])
            ibel.cat_interpreter # on remplit les champs cat
            ibel.payment_mode_interpreter # on tente de remplir le champ mode de paiement
            lirs << ibel
            position += 1 
            
          end
          index += 1
        end
        lirs
      rescue CSV::MalformedCSVError
        # puts 'dans le rescue de lecture du csv'
        errors.add(:read, "Fichier mal formé, fin de la lecture en ligne #{index}")
        lirs
      end
    end
    
    protected
  
    # controle la validité d'une ligne. Si les transformations
    # échoues (to_f ou Date.parse) on arrive dans le bloc et la ligne 
    # n'est pas lue.
    def correct?(row, index)
      # row[3] et row[2] ne doivent pas être vide tous les deux
      return false if row[2] == nil && row[3] == nil
      row[0] = guess_date(row[0], index) # on peut lire la date
      row[1] = correct_narration(row[1])
      row[2] ||= '0.0' # on remplace les nil par des zéros
      row[3] ||= '0.0'
      # on remplace la virgule décimale et on le transforme en chiffre        
      row[2] = row[2].gsub(',','.').to_d.round(2)  # on peut faire un chiffre du débit
      row[3] = row[3].gsub(',','.').to_d.round(2)  # on peut faire un chiffre du crédit
      true
    rescue Exception =>e 
        
      #        puts e.backtrace.inspect  
      errors.add(:base, 
        "Ligne #{index} non conforme : #{e.message}") 
      Rails.logger.info "Lecture de fichier csv : une erreut s est produite #{row}"
      false
    end
      
    
  end
  
end  