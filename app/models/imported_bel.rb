# La classe ImportedBel représente une ligne importée d'un relevé de compte 
# bancaire. 
# 
# Cette classe est ensuite destinée à créer des compta_line qui seront rattachés 
# à l'extrait bancaire correspondant. 
# 
# Ne pas confondre cette classe avec les BankExtractLines qui sont des lignes 
# faisant le lien entre un extrait de compte et les compta_lines. 
# 
# Les ImportedBel sont des objets à priori transitoires (une autre option de 
# programmation aurait été de les importer comme des BankExtractLines et de 
# les gérer dans la même table. 
# 
# Cette méthode n'a pas été retenue pour ne pas mettre dans la classe BankExtractLine
# trop de responsabilité. Et des perturbations éventuelles avec de nombreux imports 
# inaboutis. Il aurait par exemple fallu retirer le champ bank_extract_id des validations
# car une BankExtractLine doit appartenir à un bank_extract_id.
# 
# Un ImportedBel appartient à un compte bancaire
# 
# Les Catégories sont 
# - T pour un transfert interne
# - C pour un crédit
# - D pour un débit
# - R pour une remise chèque
# 
#

class ImportedBel < ActiveRecord::Base
  
  attr_accessible :date, :narration, :debit, :credit, :position, 
    :bank_account_id, :ref, :nature_id, :destination_id, :payment_mode, :cat
  
  belongs_to :bank_account
  belongs_to :destination
  belongs_to :nature
  
  validates :date, :narration, presence:true
  validates :debit, :credit, presence:true, numericality:true, :not_null_amounts=>true, :not_both_amounts=>true, two_decimals:true  # format: {with: /^-?\d*(.\d{0,2})?$/}

  
  # indique si une ImportedBel est une dépense. 
  # nil si debit et credit sont tous deux à zero (ce qui n'est pas valide)
  def depense?
    return true if debit != 0.0
    return false if credit != 0.0
  end
  
  def recette?
    return true if credit != 0.0
    return false if debit != 0.0
  end
  
  # constate que les trois champs sont remplis
  # on n'utilise pas un système de validation car best_in_place oblige à remplir
  # par champ et non tous les champs d'un coup.
  #
  # Si c'est un transfert, payment_mode est suffisant
  #
  def complete?
    return true if cat == 'T' && payment_mode
    nature_id && destination_id && payment_mode
  end
  
  
  
  
  
  
  # interpreter tente de compléter les champs de imported_bel par 
      # la lecture des données et notamment de la narration.
      # 
      # A terme, il faudra mettre cette méthode dans une classe spécifique 
      # et envisager des classes enfants pour différentes banques
      # 
      # La méthode renvoie hash de données qui sera utilisé pour un imported_bel
      #
      def cat_interpreter
        # si c'est une dépense on passe le champ cat à D, sinon à C
        self.cat = depense? ? 'D' : 'C' 
        # si c'est une dépense et que le libellé est retrait on passe cat à T
        self.cat = 'T' if depense? && narration=~/Retrait/
        # R pour Remise Chèque
        self.cat = 'R' if recette? && narration=~/Remise/
      end
      
      def payment_mode_interpreter
        if depense?
        self.payment_mode = 'CB' if narration=~/Carte/
        self.payment_mode = 'Prélèvement' if narration=~/Prelevement|Prelevmnt|Echeance|Interbancaire/
        self.payment_mode = 'Virement' if narration=~/Virement/
        self.payment_mode = 'Chèque' if narration=~/Cheque/
        else
        self.payment_mode = 'Virement' if narration=~/Virement/
        end
      end
      
      
      
end