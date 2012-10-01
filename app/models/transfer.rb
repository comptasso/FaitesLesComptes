# coding: utf-8

class Transfer < Writing
  
  before_destroy :should_be_destroyable 

  alias children compta_lines

  # on veut un montant unique dans le formulaire donc on fait un
  attr_accessor :amount

  before_save :fill_amount
  
  def line_to
    compta_lines.where('debit <> ?', 0)
  end

  def line_from
    compta_lines.where('credit <> ?', 0)
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
    self.lines.select {|l| l.locked? }.empty?
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

  def fill_amount
    line_to.debit = amount
    line_from.credit = amount
  end
 
  # callback appelé par before_destroy pour empêcher la destruction des lignes
  # et du transfer si une ligne est verrouillée
  def should_be_destroyable
    return self.destroyable?
  end

end
