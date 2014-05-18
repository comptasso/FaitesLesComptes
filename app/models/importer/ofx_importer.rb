require 'ofx'

# Classe destinée à lire les écritures d'un relevé bancaire à partir d'un
# fichier OFX-money. 
# 
# La mise au point se fait à partir d'un fichier venant du crédit Agricole.
# Les écritures sont lues par account.transactions 
# 
# Voici les informations fournies
# 
# #<OFX::Transaction:0xace3d1c @amount=#<BigDecimal:ac67938,'-0.1E3',9(18)>, 
# @amount_in_pennies=-10000, 
# @fit_id="3597400034599",
# @memo="PRELEVEMENT",
# @name="PREDICA PREDISSIME 9     237434",
# @payee="", @check_number="", @ref_number="",
# @posted_at=2014-05-16 00:00:00 +0200, @type=:other, @sic=""> 
# 
# Nous alons donc retenir les champs @posted_at pour la date, @amount pour 
# le montant, et @name pour la narration
#
module Importer
  class OfxImporter < BaseImporter 
    
    
    
    def load_imported_rows(options = nil)
      lirs = []
      
      position = 1
      transacs = []
      # permet d'avoir à la fois un fichier temporaire comme le prévoit rails
      # ou un nom de fichier (ce qui facilite les tests et essais).
      f = file.respond_to?(:tempfile) ? file.tempfile : file
      begin
        OFX(f) {transacs = account.transactions } 
        rows = transacs.map {|t| build_row(t)}  
        rows.each do |row|
          # vérification des champs pour les lignes autres que la ligne de titre
          prepare(row)
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
        lirs
        
      rescue OFX::UnsupportedFileError
        errors.add(:read, "Erreur de lecture du Fichier OFX")
        lirs
      end
    end
    
    protected
    
    def build_row(transac)
      debit, credit = debit_credit transac.amount
      [transac.posted_at, transac.name, debit, credit]
    end
  
    # controle la validité d'une ligne. Si les transformations
    # échoues (to_f ou Date.parse) on arrive dans le bloc et la ligne 
    # n'est pas lue.
    def prepare(row)
      # row[3] et row[2] ne doivent pas être vide tous les deux
      return false if row[2] == nil && row[3] == nil
      row[0] = row[0].to_date
      row[1] = correct_narration(row[1])
      row[2] ||= '0.0' # on remplace les nil par des zéros
      row[3] ||= '0.0'
      # on remplace la virgule décimale et on le transforme en chiffre        
      row[2] = row[2].to_d.round(2)  # on peut faire un chiffre du débit
      row[3] = row[3].to_d.round(2)  # on peut faire un chiffre du crédit
      true
    end
  
  
    def debit_credit(amount)
      if amount < 0
        return [-amount, 0]
      else
        return [0, amount]
      end
    end
  
  end
end

