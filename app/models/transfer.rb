# coding: utf-8

# Un transfer est une écriture de virement entre deux comptes
# Un transfer ne peut donc avoir que deux compta_lines, l'une 
# qui donne (donc crédit) et l'autre qui reçoit (donc débit)
# Par convention, la première ligne est celle qui donne
# et la dernière est celle qui reçoit.
#
class Transfer < Writing

  attr_reader :compta_line_to, :compta_line_from

  has_many :compta_lines, :dependent=>:destroy, foreign_key:'writing_id'
    

  before_destroy :should_be_destroyable

  validate :correct_amount, :two_lines, :not_same_accounts
  
  
  alias original_compta_lines compta_lines
  


  # Pour toujours avoir les 2 compta_lines, compta_lines est redéfini
  def compta_lines
    if original_compta_lines.size == 0
      original_compta_lines.build(debit:0, credit:0)
      original_compta_lines.build(debit:0, credit:0)
    end
    original_compta_lines
  end


  # 3 cas de figure
  # 1 : il y a une ligne débit, on sait qui est debit et donc l'autre est crédit
  # 2 : il y a une ligne credit, id
  # 3 : on prend la première pour l'un et la seconde pour l'autres
  def set_compta_lines
    # on est sur qu'il y a deux compta_lines
    cltos = compta_lines.select {|cl| cl.debit && cl.debit != 0}
    clfroms  = compta_lines.select {|cl| cl.credit && cl.credit != 0}
    if !cltos.empty? && !clfroms.empty?
      @compta_line_to = cltos.first
      @compta_line_from = clfroms.first
    end
    if cltos.empty? && clfroms.empty?
      @compta_line_to = compta_lines.first
      @compta_line_from = compta_lines.last
    end
  end

  # amount est stocké dans les compta_lines
  def amount
    set_compta_lines unless @compta_line_to
    @compta_line_to.debit
  end


  def amount=(montant)
    set_compta_lines unless @compta_line_to
    @compta_line_to.debit = montant
    @compta_line_from.credit = montant
  end

  # Line_to est la ligne débitée
  def line_to
    set_compta_lines unless @compta_line_to
    @compta_line_to
  end

  # par convention la dernière ligne est celle qui est débitée
  def line_from
    set_compta_lines unless @compta_line_from
    @compta_line_from
  end
  
  # line_to est editable si elle n'est pas verrouillées
  def to_editable?
    !@compta_line_to.locked?
  end
  
  # line_from est editable si elle n'est pas verrouillées
  def from_editable?
    !@compta_line_from.locked?
  end
  
  # le transfert est editable si l'une des deux lignes au moins l'est
  def editable?
    to_editable? || from_editable?
  end

  # inidque si le transfer peut être détruit en vérifiant qu'aucune ligne n'a été verrouillée
  def destroyable?
    set_compta_lines unless @compta_line_to
    !@compta_line_to.locked? && !@compta_line_from.locked?
  end

  # pour indiquer que l'on ne peut modifier le compte de donneur
  def to_locked?
    @compta_line_to.locked?
  end

  # pour indiquer que l'on ne peut modifier le compte receveur
  def from_locked?
    @compta_line_from.locked?
  end
  
  # utile pour savoir que l'on ne peut toucher aux rubriques montant, narration
  # et date
  def partial_locked?
    from_locked? || to_locked?
  end

 

  private

  #  def fill_debit_credit(cl)
  #
  #    case compta_lines.size
  #    when 1 then cl.credit = @amount
  #    when 2 then cl.debit = @amount
  #    else raise 'Deja deux lignes'
  #    end
  #
  #
  #  end

  def correct_amount
    errors[:amount] << 'obligatoire' unless amount
    errors[:amount] << 'doit être un nombre' unless amount.is_a? Numeric
    errors[:amount] << 'nul !' if amount == 0
    return false unless errors[:amount].empty?
  end

  def two_lines
    unless @compta_line_to && @compta_line_from
      errors[:base] << 'Nombre de ligne incorrect ou une des lignes n a pas de valeur'
      return false
    end
  end

  def not_same_accounts
    if @compta_line_from.account_id == @compta_line_to.account_id
      errors[:base] << 'Comptes idendique'
      return false
    end
  end

  # callback appelé par before_destroy pour empêcher la destruction des lignes
  # et du transfer si une ligne est verrouillée
  def should_be_destroyable
    return destroyable?
  end

end
