# coding: utf-8 

# Un transfer est une écriture de virement entre deux comptes
# Un transfer ne peut donc avoir que deux compta_lines, l'une 
# qui donne (donc crédit) et l'autre qui reçoit (donc débit)
# 
# Par convention, la première ligne est celle qui donne
# et la dernière est celle qui reçoit. La clause order:'credit DESC'
# permet de s'assurer que c'est bien dans cet ordre que les lignes 
# sont retournées (ce qui est important pour le formulaire qui affiche
# le select De avant le select Vers
#
# Un transfert ne peut être détruit si une de ses lignes est verrouillée.
# Un before_destroy dans compta_line gère cette vérification.
# 
#
class Transfer < Writing

  has_many :compta_lines, -> { order('credit DESC')},
    :dependent=>:destroy, foreign_key:'writing_id'

#  attr_accessible :amount

  validates :compta_lines, :exactly_two_compta_lines=>true, :not_same_accounts=>true
  validates :amount, :numericality=>{:greater_than=>0, :message=>'doit être un nombre positif'}
  validates :date, :narration, presence:true # on répète ces validates pour avoir les * automatiquement dans la vue

  before_destroy :should_be_destroyable
  
  
  # ajoute les deux lignes de l'écriture à l'instance du transfert.
  # La valeur par défaut du montant est zero.
  def add_lines(amount = 0)
   compta_lines.new(debit:0, credit:amount)  
   compta_lines.new(debit:amount, credit:0)
  end
  
  # retourne la ligne correspondant au compte qui reçoit le montant
  # donc la ligne débitée. Le compta_lines.last est là pour renvoyer une
  # ligne même si c'est un nouveau transfert qui a encore son montant à zero
  def compta_line_to
    compta_lines.last unless compta_lines.empty?
  end

  alias line_to compta_line_to

  # retourne la ligne correspondant au compte qui donne le montant
  # donc la ligne créditée
  def compta_line_from
    compta_lines.first unless compta_lines.empty?
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

  
  # utile pour savoir que l'on ne peut toucher aux rubriques montant, narration
  # et date
  def partial_locked?
    !(to_editable? && from_editable?)
  end

  
  # line_to est editable si la compta_line qu'elle représente existe et n'est pas verouillée ni pointée
  def to_editable?
    clt = compta_line_to
    clt && clt.editable?
  end
  
   # line_from est editable si la compta_line qu'elle représente existe et est editable
  def from_editable?
    clf = compta_line_from
    clf && clf.editable?
  end
  
  # le transfert est editable si l'une des deux lignes au moins l'est
  # Cette méthode est légèrement différente de celle de Writing
  # car pour Writing editable? est vrai si toutes les lignes le sont
  # tandis qu'ici, il suffit que l'une des deux le soit.
  #
  # Ceci permet de corriger un transfert pour lequel on se serait trompé sur la 
  # compte bénéficiaire, alors qu'on aurait déjà pointé la caisse.
  def editable?
    to_editable? || from_editable?
  end

  # indique si le transfer peut être détruit en vérifiant qu'aucune ligne n'a été verrouillée
  def destroyable?
    to_editable? && from_editable?
  end
  
  protected
  
  def fill_date_piece
    self.date_piece = date 
  end

  private

  def should_be_destroyable
    compta_lines(true) # s'assure que les caches sont bien effacés
    destroyable?
  end


  

end
