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

  # La condition est mise ici pour que check_deposit.new soit associée d'emblée
  # à toutes les lignes qui correspondant aux chèques en attente d'encaissement
  # de l'organisme correspondant.
  belongs_to :bank_account 
  belongs_to :bank_extract_line
  
  has_many :checks, class_name: 'Line',
    conditions: proc { ['account_id = ? AND debit > 0', rem_check_account.id] },
    dependent: :nullify,
    before_remove: :cant_if_pointed, #on ne peut retirer un chèque si la remise de chèque a été pointée avec le compte bancaire
    before_add: :cant_if_pointed
 
  has_many :lines # utile pour les méthode credit_line et debit_line

  scope :within_period, lambda {|from_date, to_date| where(['deposit_date >= ? and deposit_date <= ?', from_date, to_date])}
  scope :not_pointed, where('bank_extract_line_id IS NULL')

  validates :bank_account_id, :deposit_date, :presence=>true
  validates :bank_account_id, :deposit_date, :cant_change=>true,  :if=> :has_bank_extract_line? 
 
  before_validation :not_empty # une remise chèque vide n'a pas de sens

  after_create :create_lines
  after_update :update_lines

  before_destroy :cant_destroy_when_pointed, :destroy_lines


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
  # avec le total des chèques déposé. Credit_line, retourne cette ligne
  def credit_line
    lines.where('credit > 0').first
  end

  # la ligne débit est la ligne enfant de credit_line
  def debit_line
    credit_line.children.first
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

  # TODO utiliser la classe pick_date

  def pick_date
    deposit_date ? (I18n::l deposit_date) : nil
  end

  def pick_date=(string)
    s = string.split('/')
    self.deposit_date = Date.civil(*s.reverse.map{|e| e.to_i})
  rescue ArgumentError
    self.errors[:deposit_date] << 'Date invalide'
    nil
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
    if bank_extract_line
      logger.warn "Tentative d'ajouter ou de retirer une ligne à la remise de chèques #{id}, alors qu'elle est pointée sur la ligne de comte #{bank_extract_line.id}"
      raise 'Impossible de retirer un chèque d une remise pointée'
    end
  
  end

  
  # appelé par before_destroy pour interdire la destruction d'une remise de chèque pointée
  def cant_destroy_when_pointed
    if bank_extract_line
      logger.warn "Tentative de détruire la remise de chèques #{id}, alors qu'elle est pointée sur une ligne de comte #{bank_extract_line.id}"
      return false
    end
  end

  # crée l'écriture de remise de chèque
  def create_lines
    p = Organism.first!.find_period(deposit_date)
    rca = p.rem_check_account
   # on crédit le compte de remise chèque
    l = Line.create!(line_date:deposit_date, check_deposit_id:id,
      narration:'Remise chèque',
      account_id:rca.id,
      credit:total_checks,
      book_id:OdBook.first!.id)
    # et on débite la banque
    ba = bank_account.current_account(p)
    Line.create!(line_date:deposit_date, check_deposit_id:id,
      narration:'Remise chèque',
      debit:total_checks,
      account_id:ba.id,
      book_id:OdBook.first!.id,
    owner_id:l.id,
    owner_type:'Line')
    
  end

  def update_lines
    credit_line.update_attribute(:credit, total_checks)
    debit_line.update_attribute(:debit, total_checks)
  end

 # before_destroy callback
  def destroy_lines
    debit_line.destroy
    credit_line.destroy # dans cet ordre car débit_line est obtenu via credit_line
  end
  

  

 
  def has_bank_extract_line?
    bank_extract_line ? true : false
  end
  
end
