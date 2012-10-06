# coding: utf-8

# Le modèle CheckDeposit correspond à une remise de chèques. La logique est de 
# pouvoir préparer une remise de chèque à partir d'une banque (obligation du bank_account)
# et de remplir cette remise avec les checks (qui sont des chèques à encaisser), liste
# fournie par Account.pending_checks.
#
# On peut ensuite ajouter ou retirer des chèques d'une remise. 
#
# Après dépôt à la banque, le relevé bancaire servira à valider la remise
# qui ne peut plus être modifiée.
# Lors de l'ajout ou du retrait des chèques et au moment de la sauvegarde,
# le champ check_deposit_id des lignes concernées est rempli avec l'id de la remise.
# On ne sert pas du champ bank_account_id
# 
# Des lignes d'écritures sont passées : 
# Au crédit du compte 511 pour contrepasser les chèques 
# et au débit du compte de banque.
#
# C'est la présence de bank_extract_line qui indique que le check_deposit à été pointé
# et ne peut plus être modifié, ce qui veut dire aussi qu'on ne peut plus retirer ou
# ajouter des chèques à cette remise
# 
class CheckDeposit < ActiveRecord::Base


  include Utilities::PickDateExtension # apporte les méthodes pick_date_for

  pick_date_for :deposit_date
  
  belongs_to :bank_account 
  belongs_to :bank_extract_line
  belongs_to :writing, :dependent=>:destroy
  

  # La condition est mise ici pour que check_deposit.new soit associée d'emblée
  # à toutes les lignes qui correspondant aux chèques en attente d'encaissement
  # de l'organisme correspondant.
  has_many :checks, class_name: 'Line',
    conditions: proc { ['account_id = ? AND debit > 0', rem_check_account.id] },
    dependent: :nullify,
    before_remove: :cant_if_pointed, #on ne peut retirer un chèque si la remise de chèque a été pointée avec le compte bancaire
    before_add: :cant_if_pointed
 
  # has_many :lines # utile pour les méthode credit_compta_line et debit_compta_line
  has_many  :compta_lines, :through=>:writing

  alias children compta_lines

  scope :within_period, lambda {|from_date, to_date| where(['deposit_date >= ? and deposit_date <= ?', from_date, to_date])}
 

  validates :bank_account_id, :deposit_date, :presence=>true
  validates :bank_account_id, :deposit_date, :cant_change=>true,  :if=> :pointed?
  validate :not_empty

 #  before_validation :not_empty # une remise chèque vide n'a pas de sens

  after_create :create_writing
  after_update :update_writing

  before_destroy :cant_destroy_when_pointed

  
  # permet de trouver les cheques à encaisser pour  tout l'organisme
  def self.pending_checks
     Line.pending_checks.all
  end


  # donne le total des chèques à encaisser pour cet organisme
  def self.total_to_pick
    pending_checks.sum(&:debit)
  end

  # donne le nombre total des chèques à encaisser pour un organisme
  def self.nb_to_pick
    pending_checks.size
  end

  # lorsque la remise de chèque est sauvegardée, il y a création d'une ligne au crédit du compte 511
  # avec le total des chèques déposé. credit_compta_line, retourne cette ligne
  # persisted? est là pour éviter qu'on recherche une credit_compta_line ou une debit_compta_line alors qu'elles ne
  # sont pas encore créées.
  def credit_compta_line
     persisted? ? compta_lines.where('credit > 0').first : nil
  end
  
  def credit_line
    credit_compta_line.to_line if credit_compta_line
  end




  # persisted? est là pour éviter qu'on recherche une credit_compta_line ou une debit_compta_line alors qu'elles ne
  # sont pas encore créées.
  def debit_compta_line
    persisted? ? compta_lines.where('debit > 0').first : nil
  end

  def debit_line
    debit_compta_line.to_line if debit_compta_line
  end

  # la remise chèque est pointée si la ligne débit est connectée à
  # un bank_extract_line
  def pointed?
    debit_compta_line && debit_compta_line.bank_extract_lines.any?
  end

  # retourne le nombre de chèque dans cette remise
  def nb_checks
    checks.count
  end

  # total checks fait la somme des chèques qui sont dans la cible de l'association.
  # cette approche est nécessaire car un module intégré donne un résultat vide
  def total_checks
    if new_record?
      return association(:checks).target.sum {|l|  l.debit}
    else
      checks.sum(:debit)
    end
  end

  # pour remplir la remise de chèques avec la totalité des chèques disponibles
  def pick_all_checks
    CheckDeposit.pending_checks.each {|l| checks << l}
  end

  

  def rem_check_account
    Organism.first!.find_period(deposit_date).rem_check_account
  end

  
  private

  # appelé par before_save pour éviter les remises chèques vides
  # TODO devrait être un validator
  def not_empty
    self.errors[:base] <<  'Il doit y avoir au moins un chèque dans une remise' if checks.empty?
  end


  # appelé par before_add et before_remove pour interdire l'ajout
  # ou le retrait de chèque sur une remise pointée
  def cant_if_pointed(line)
    if pointed?
      logger.warn "Tentative d'ajouter ou de retirer une ligne à la remise de chèques #{id}, alors qu'elle est pointée."
      raise 'Impossible de retirer un chèque d une remise pointée'
    end
  
  end

  
  # appelé par before_destroy pour interdire la destruction d'une remise de chèque pointée
  def cant_destroy_when_pointed
    if pointed?
      logger.warn "Tentative de détruire la remise de chèques #{id}, alors qu'elle est pointée"
      return false
    end
  end

  def create_writing
    book = OdBook.first!
    w = build_writing(date:deposit_date, narration:'Remise chèque', book_id:book.id)
    w.compta_lines.build(check_deposit_id:id, account_id:rem_check_account.id, credit:total_checks)
    w.compta_lines.build(check_deposit_id:id, debit:total_checks, account_id:bank_account_account.id)
    w.save!
    self.update_attribute(:writing_id, w.id)
  end

  
  def bank_account_account
    bank_account.current_account(Organism.first!.find_period(deposit_date))
  end

  def update_writing
    credit_compta_line.update_attribute(:credit, total_checks)
    debit_compta_line.update_attribute(:debit, total_checks)
  end

  # crée l'écriture de remise de chèque
#  def create_lines
#    p = Organism.first!.find_period(deposit_date)
#    rca = p.rem_check_account
#   # on crédit le compte de remise chèque
#    l = lines.create!(line_date:deposit_date, check_deposit_id:id,
#      narration:'Remise chèque',
#      account_id:rca.id,
#      credit:total_checks,
#      book_id:OdBook.first!.id)
#    # et on débite la banque
#    ba = bank_account.current_account(p)
#    lines.create!(line_date:deposit_date, check_deposit_id:id,
#      narration:'Remise chèque',
#      debit:total_checks,
#      account_id:ba.id,
#      book_id:OdBook.first!.id)
#
#  end

#  def update_lines
#    credit_compta_line.update_attribute(:credit, total_checks)
#    debit_compta_line.update_attribute(:debit, total_checks)
#  end
 
  def has_bank_extract_line?
    bank_extract_line ? true : false
  end
  
end
