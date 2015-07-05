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
# Pour la gestion du champ DatePiece, on a choisi d'utiliser le champ writing_date
# qui était précédemment utilisé pour saisir la date. Cela permet un patch 
# facile. Mais fait qu'on considère que la date de l'opération ne peut plus être
# modifiée et reste la date d'écriture sur le relevé. 
# TODO voir éventuellement à faire évoluer ce sujet à terme
# TODO Autre sujet, la date est limitée à l'exercice, alors que la date de la pièce
# peut être antérieure. Voir éventuellement à modifier la borne du calendrier
# sauf si on fait évoluer le mode de saisie vers une modal box, probablement 
# souhaitable.
# TODO Et enfin, si on reste comme ça, il faudra alors changer le champ
# writing_date en writing_date_piece. 
#

class ImportedBel < ActiveRecord::Base
  include Utilities::PickDateExtension
  
#  attr_accessible :date, :writing_date, :writing_date_picker, :narration, :debit, :credit, :position, 
#    :bank_account_id, :ref, :nature_id, :destination_id, :payment_mode, :cat
  
  # utilise le module Utilities::PickDateExtension pour créer des virtual attributes
  # date_picker
  pick_date_for :writing_date
  
  belongs_to :bank_account
  belongs_to :destination
  belongs_to :nature
  
  belongs_to :writing
  
  validates :date, :narration, presence:true
  validates :narration, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MEDIUM_NAME_LENGTH_MAX}
  validates :debit, :credit, presence:true, numericality:true, :not_both_null_or_full=>true, two_decimals:true  # format: {with: /^-?\d*(.\d{0,2})?$/}
  validates :cat, inclusion: {in:%w(D C T R)}
  
  # on initialise writing_date avec la date du relevé
  before_create 'self.writing_date = date'
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
  
  # méthode ajoutée pour aider le validator
  def values
    debit || credit
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
  
  # renvoie le hash permettant de générer la Writing ou le Transfert
  def to_write
    # vérification que l'ibel est writable
    return nil unless valid?
    unless complete?
      errors.add(:base, 'Informations manquantes')
      return nil
    end
    case cat
      when 'T' then complete_transfer_params 
      else
        complete_writing_params
      end
   end
   
  def imported?
    writing_id ? true :false
  end
  
  
  def importable?(range_date)
    return false if imported? # déjà importée
    return false unless date # n'a pas de date pour comparer
    date.in?(range_date) rescue false # permet de transmettre un range_date nil
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
  
  
  
  # construit seulement les paramètres de l'écriture.
  # 
  def complete_writing_params
    writing_params.merge(:compta_lines_attributes=>
        {'0'=>line_params, '1'=>counter_line_params})
  end
  
  def complete_transfer_params
    writing_params.merge(:compta_lines_attributes=>
        {'0'=>transfer_params, '1'=>counter_transfer_params})
  end
  
  
  def transfer_params
    from = depense? ? bank_account : to_accountable
    {debit:credit, credit:debit, 
      account_id:from.current_account(current_period).id }
  end
  
  def counter_transfer_params
    to = depense? ? to_accountable : bank_account
    {debit:debit, credit:credit, 
      account_id:to.current_account(current_period).id }
  end
  
  def current_period
    @current_period || Organism.first.find_period(date) if date
  end
  
  # TODO changer le champ writing_date en writing_date_piece
  def writing_params
    {date:date, ref:ref, narration:narration, date_piece:writing_date}
  end
  
  def line_params
    {nature_id:nature_id, debit:debit, credit:credit, 
      destination_id:destination_id}
  end
  
  def counter_line_params
    {payment_mode:payment_mode, debit:credit, credit:debit,
      account_id:bank_account.current_account(current_period).id}
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