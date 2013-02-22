# coding: utf-8

# Un transfer est une écriture de virement entre deux comptes
# Un transfer ne peut donc avoir que deux compta_lines, l'une 
# qui donne (donc crédit) et l'autre qui reçoit (donc débit)
# Par convention, la première ligne est celle qui donne
# et la dernière est celle qui reçoit.
#
# Un transfert ne peut être détruit si une de ses lignes est verrouillée.
# Un before_destroy dans compta_line gère cette vérification.
# 
#
class Transfer < Writing

  has_many :compta_lines, :dependent=>:destroy, foreign_key:'writing_id'

  attr_accessible :amount

  # validate :correct_amount, :two_lines, :not_same_accounts
  validates :compta_lines, :exactly_two_compta_lines=>true, :not_same_accounts=>true
  validates :amount, :numericality=>{:greater_than=>0, :message=>'doit être un nombre positif'}

  before_destroy :should_be_destroyable

  # TODO vérifier que ce within_period n'est pas déja défini dans writing
  scope :within_period, lambda {|p| where('date >= ? AND date <= ?', p.start_date, p.close_date)}

  

  # ajoute les deux lignes de l'écriture à l'instance du transfert.
  # La valeur par défaut du montant est zero.
  def add_lines(amount = 0)
   compta_lines.new(debit:0, credit:amount) 
   compta_lines.new(debit:amount, credit:0)
  end
  
  # retourne la ligne correspondant au compte qui reçoit le montant
  # donc la ligne débitée
  def compta_line_to
    unless compta_lines.empty?
      compta_lines.select{|l| l.debit != 0}.first || compta_lines.last
    end
  end

  alias line_to compta_line_to

  # retourne la ligne correspondant au compte qui donne le montant
  # donc la ligne créditée
  def compta_line_from
    unless compta_lines.empty?
      compta_lines.select{|l| l.credit != 0}.first || compta_lines.first
    end
  end

  alias line_from compta_line_from

  # amount est stocké dans les compta_lines
  def amount
   compta_line_to ? compta_line_to.debit : 0
  end

  # amount est stocké dans les compta_lines, mais celles ci ne sont créées que si
  # nécessaire, d'où la nécessité de ce else.
  #
  # Une autre approche serait d'ajouter les lignes lors de la création de l'instance
  # mais cela génère des difficultés avec le formulaire de création en cas de
  # réaffichage de la vue (du fait probablement des nested_attributes.
  def amount=(montant)
    if compta_line_to && compta_line_from
      compta_line_to.debit = montant
      compta_line_from.credit = montant
    else
      add_lines(montant) 
    end
  end

  
   # pour indiquer que l'on ne peut modifier le compte du receveur
  def to_locked?
    compta_line_to && compta_line_to.locked?
  end

  # pour indiquer que l'on ne peut modifier le compte du donneur
  def from_locked?
    compta_line_from && compta_line_from.locked?
  end

  # utile pour savoir que l'on ne peut toucher aux rubriques montant, narration
  # et date
  def partial_locked?
    from_locked? || to_locked? 
  end

  
  # line_to est editable si elle n'est pas verrouillées
  def to_editable?
    !to_locked?
  end
  
  # line_from est editable si elle n'est pas verrouillées
  def from_editable?
    !from_locked?
  end
  
  # le transfert est editable si l'une des deux lignes au moins l'est
  def editable?
    to_editable? || from_editable?
  end

  # inidque si le transfer peut être détruit en vérifiant qu'aucune ligne n'a été verrouillée
  def destroyable?
    to_editable? && from_editable?
  end

 
  
  
 

  private

  def should_be_destroyable
    compta_lines.locked.empty?
  end

  def correct_amount
    errors[:amount] << 'obligatoire' unless amount
    errors[:amount] << 'doit être un nombre' unless amount.is_a? Numeric
    errors[:amount] << 'nul !' if amount == 0
    return false unless errors[:amount].empty?
  end

  def two_lines
    if compta_line_to || compta_line_from
      errors[:base] << 'Nombre de ligne incorrect ou une des lignes n a pas de valeur'
      return false
    end
  end

  def not_same_accounts
    if compta_line_from.account_id == compta_line_to.account_id
      errors[:base] << 'Comptes idendiques'
      return false
    end
  end

  

end
