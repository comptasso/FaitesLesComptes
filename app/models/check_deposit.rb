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
  belongs_to :check_deposit_writing, :dependent=>:destroy, :foreign_key=>'writing_id'
  
  has_many :checks, 
    ->(owner) { where('account_id = ? AND debit > 0', owner.rem_check_account_id) },
    class_name: 'ComptaLine',
    # conditions: proc { ['account_id = ? AND debit > 0', rem_check_account_id] },
    dependent: :nullify,
    before_remove: :cant_if_pointed, #on ne peut retirer un chèque 
    # si la remise de chèque a été pointée avec le compte bancaire
    before_add: :cant_if_pointed
 
  # utile pour les méthode credit_compta_line et debit_compta_line
  has_many  :compta_lines, :through=>:check_deposit_writing
  
  alias children compta_lines

  # book_id est nécessaire car on construit les écritures
  # attr_accessible :deposit_date, :deposit_date_picker, :check_ids, :bank_account_id

  scope :within_period, lambda {|p| where(['deposit_date >= ? and deposit_date <= ?', p.start_date, p.close_date])}
 
  validates :bank_account_id, :deposit_date, :presence=>true
  validates :bank_account_id, :deposit_date, :cant_change=>true, :if=> :pointed?
  # ce qui du coup interdit aussi la destruction
  # TODO ne semble plus vrai
  validate :not_empty # une remise chèque vide n'a pas de sens

  after_create :create_writing
  before_destroy :check_pointed
  after_update :update_writing 
  
  # permet de trouver les cheques à encaisser pour  tout l'organisme ou pour un 
  # secteur donné
  def self.pending_checks(sector = nil)
    if sector
      ComptaLine.sectored_pending_checks(sector).to_a
    else
      ComptaLine.pending_checks.to_a
    end
  end

  # donne le total des chèques à encaisser pour cet organisme
  def self.total_to_pick(sector = nil)
    pending_checks(sector).sum(&:debit)
  end

  # donne le nombre total des chèques à encaisser pour un organisme
  def self.nb_to_pick(sector = nil)
    pending_checks(sector).size
  end

  # lorsque la remise de chèque est sauvegardée, il y a création d'une ligne au crédit du compte 511
  # avec le total des chèques déposé. credit_compta_line, retourne cette ligne
  # persisted? est là pour éviter qu'on recherche une credit_compta_line ou une debit_compta_line alors qu'elles ne
  # sont pas encore créées.
  def credit_compta_line
    persisted? ? compta_lines.where('credit > 0').first : nil
  end
  
  def credit_line
    credit_compta_line if credit_compta_line
  end

  # persisted? est là pour éviter qu'on recherche une credit_compta_line
  # ou une debit_compta_line alors qu'elles ne sont pas encore créées.
  def debit_compta_line
    persisted? ? compta_lines.where('debit > 0').first : nil
  end

  def debit_line
    debit_compta_line if debit_compta_line
  end

  # la remise chèque est pointée si la ligne débit est connectée à
  # un bank_extract_line
  def pointed?
    debit_compta_line && debit_compta_line.bank_extract_line
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

  # pour remplir la remise de chèques avec la totalité des chèques disponibles dans un secteur donné
  def pick_all_checks(sector)
    CheckDeposit.pending_checks(sector).each {|l| checks << l}
  end

  def rem_check_account
    return nil unless bank_account_id
    p = bank_account.organism.find_period(deposit_date)
    p.rem_check_account
  end
  
  def rem_check_account_id
    rca = rem_check_account
    rca ? rca.id : nil 
  end
  

  
  private

  # méthode de validation pour éviter des remises vides
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
  
  def check_pointed
    if pointed?
      puts 'dans pointed?'
      logger.warn "Tentative de détruire la remise de chèques #{id}, alors qu'elle est pointée."
      raise 'Impossible de détruire une remise de chèque pointée'
    end
  end

  

  def create_writing
    book = OdBook.first!
    CheckDeposit.transaction do
      w = build_check_deposit_writing(date:deposit_date, narration:'Remise chèque', book_id:book.id)
      w.user_ip = user_ip
      w.written_by = written_by
      w.compta_lines.build(check_deposit_id:id, account_id:rem_check_account.id, credit:total_checks)
      w.compta_lines.build(check_deposit_id:id, debit:total_checks, account_id:bank_account_account.id)
      w.save!
      self.update_attribute(:writing_id, w.id) 
    end
  end

  
  def bank_account_account
    bank_account.current_account(bank_account.organism.find_period(deposit_date))
  end

  def update_writing
    CheckDeposit.transaction do
      check_deposit_writing.date = deposit_date
      check_deposit_writing.user_ip = user_ip
      check_deposit_writing.written_by = written_by
      check_deposit_writing.save
      credit_compta_line.update_attribute(:credit, total_checks)
      debit_compta_line.update_attribute(:debit, total_checks)
    end
  end
  
end
