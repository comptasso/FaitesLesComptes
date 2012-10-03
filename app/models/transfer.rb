# coding: utf-8

# Un transfer est une écriture de virement entre deux comptes
# Un transfer ne peut donc avoir que deux compta_lines, l'une 
# qui donne (donc crédit) et l'autre qui reçoit (donc débit)
# Par convention, la première ligne est celle qui donne
# et la dernière est celle qui reçoit.
#
class Transfer < Writing
  
  before_destroy :should_be_destroyable 

  alias children compta_lines

  attr_accessor :amount

  
  def amount
    compta_lines.first.credit
  end

  def line_to
    compta_lines.where('debit <> ?', 0).first
  end

  def line_from
    compta_lines.where('credit <> ?', 0).first
  end
  
  def to_editable?
    !line_to.locked?
  end

  
  def from_editable?
    !line_from.locked?
  end
  
  def editable?
    to_editable? || from_editable?
  end

  # inidque si le transfer peut être détruit en vérifiant qu'aucune ligne n'a été verrouillée
  def destroyable?
    compta_lines.select {|l| l.locked? }.empty?
  end

  # pour indiquer que l'on ne peut modifier le compte de donneur
  def to_locked?
    line_to ? line_to.locked : false
  end

  # pour indiquer que l'on ne peut modifier le compte receveur
  def from_locked?
    line_from ? line_from.locked : false
  end
  
  # utile pour savoir que l'on ne peut toucher aux rubriques montant, narration 
  # et date
  def partial_locked?
    from_locked? || to_locked?
  end

 

  private

  # callback appelé par before_destroy pour empêcher la destruction des lignes
  # et du transfer si une ligne est verrouillée
  def should_be_destroyable
    return self.destroyable?
  end

end
