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
# Les validations restent très souples afin de pouvoir modifier les enregistrements
# dans le formulaire avec best_in_place. Ainsi, nature_id, payment_mode et 
# destination_id ne sont pas obligatoires. 
# 
# Les champs obligatoires sont en fait ceux qui sont préremplis par le BelsImporter
# à la lecture du fichier.
#

class ImportedBel < ActiveRecord::Base
  
  attr_accessible :date, :narration, :debit, :credit, :position, 
    :bank_account_id, :ref, :nature_id, :destination_id, :payment_mode, :cat
  
  belongs_to :bank_account
  belongs_to :destination
  belongs_to :nature
  
  validates :date, :narration, presence:true
  validates :debit, :credit, presence:true, numericality:true, :not_null_amounts=>true, :not_both_amounts=>true, two_decimals:true  # format: {with: /^-?\d*(.\d{0,2})?$/}
  validates :cat, inclusion: {in:%w(D C T R)}
  # on fait un reset du payment_mode si on a changé de catégorie, ceci pour 
  # que dans la vue index, et en cas de changement par best_in_place de la catégorie,
  # on ne reste pas avec des valeurs inadaptées pour le payment_mode.
  before_update 'self.payment_mode = nil', :if=>'cat_changed?' 
    
  
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
  
  
  # méthode destinée à écrire l'écriture comptable proprement dite
  # et la bank_extract_line qui lui est associée
  def write
    # vérification que l'ibel est writable
    return false unless valid?
    unless complete?
      errors.add(:base, 'Informations manquantes')
      return false
    end
    ImportedBel.transaction do
      # case appel des méthodes protégées spécialisées
      writing = case cat
        when 'T' then write_transfer # méthode qui écrit le transfert et la bank_extract_line
        when 'D' then write_depense
      end
    # Ne pas oublier de détruire l'ibel puisqu'on ne devra plus l'importer
    # il s'agit d'une action qui doit être faite dans le controller
      writing # on renvoie la writing car celà va permettre au controller de 
      # afficher le numéro de l'écriture
    end 
    
    
    # 
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
  
  protected
  
  # write_transfer écrit le transfert défini par l'ImportedBel
  # puis écrit la bank_extract_line correspondante
  def write_transfer
    # savoir dans quel sens on doit faire le transfert
    if depense?
      from = bank_account
      to = to_accountable # trouve la caisse ou la banque qui reçoit
      amount = debit
    else
      to = bank_account
      from = to_accountable
      amount =  credit
    end
    t = Transfer.write(from, to, amount, date, narration, ref)
    # on cherche maintenant la compta_line qui correspond à bank_account
    cl = depense? ? t.compta_line_from : t.compta_line_to 
    # puis  l'extrait qui correspond à la date
    bex = bank_account.bank_extracts.where('begin_date <= ? AND end_date >= ?', date, date).first
    # pour créer la bank_extract_line en précisant sa position
    new_bel = bex.bank_extract_lines.new(compta_line_id:cl.id)
    new_bel.save
    # TODO faut-il se préoccuper de  la position ? On peut bien sur valider
    # les écritures dans le désordre mais celà est probablement de la responsabilité du user.
    
    # TODO voir comment enregistrer les user_id et ip
    t
  end
  
  # write_depense écrit une écriture qui est venue au débit du compte
  def write_depense
    # trouver le livre sur lequel on doit écrire
    book = bank_account.sector.outcome_book
    params = {date:date, ref:ref, narration:narration,
      compta_lines_attributes:{[0]=>{nature_id:nature_id, 
          destination_id:destination_id,
          payment_mode:payment_mode,
          account_id:nature.account_id,
          debit:debit,
          credit:0},
      [1]=>{account_id:bank_account.current_account(Organism.first.find_period(date)),
          debit:0, credit:debit}},
    }
    w = book.in_out_writings.build(params)
    w.save!
    
  end
  
  # permet de trouver la banque ou la caisse à partir du champ payment_mode
  # la valeur est de la forme bank_xx ou cash_xx 
  # 
  # On cherche donc la caisse ou la banque
  #
  def to_accountable
    return nil unless payment_mode =~ /(bank|cash)_\d+/
    vals = payment_mode.split('_')
    case vals[0]
    when 'bank' then BankAccount.find(vals[1])
    when 'cash' then Cash.find(vals[1])
    else 
      nil
    end
  end
  
      
      
      
end