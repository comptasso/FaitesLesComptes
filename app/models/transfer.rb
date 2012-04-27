# coding: utf-8

class Transfer < ActiveRecord::Base

  # TODO il faudrait modifier line_debit et line_credit en from et towards

  before_destroy :should_be_destroyable

  belongs_to :organism
  belongs_to :debitable, :polymorphic=>true
  belongs_to :creditable, :polymorphic=>true
  has_many   :lines, :as=>:owner, :dependent=>:destroy

  validates :date, :amount, :presence=>true
  validates :debitable_id, :debitable_type, :presence=>true
  validates :creditable_id, :creditable_type, :presence=>true
  validates :amount, numericality: true
  validate :amount_cant_be_null, :required_fill_debitable, :required_fill_creditable
  validate :different_debit_and_credit

  after_create :create_lines
  after_update :update_line_debit, :unless=>lambda { self.line_debit.locked }
  after_update :update_line_credit, :unless=>lambda { self.line_credit.locked }

  # argument virtuel pour la saisie des dates
  def pick_date
    date ? (I18n::l date) : nil
  end

  def pick_date=(string)
    s = string.split('/')
    self.date = Date.civil(*s.reverse.map{|e| e.to_i})
  rescue ArgumentError
    self.errors[:date] << 'Date invalide'
    nil
  end

  # remplit les champs debitable_type et _id avec les parties 
  # model et id de l'argument.
  def fill_debitable=(model_id)
    elements = model_id.split('_')
    self.debitable_type = elements.first
    self.debitable_id = elements.last
  end


  def fill_debitable
    [debitable_type, debitable_id].join('_')
  end

  # remplit les champs creditable_type et _id avec les parties 
  # model et id de l'argument.
  def fill_creditable=(model_id)
    elements = model_id.split('_')
    self.creditable_type = elements.first
    self.creditable_id = elements.last
  end

  def fill_creditable
    [creditable_type, creditable_id].join('_')
  end

  def line_debit
    lines.where('debit <> ?', 0).first
  end

  def line_credit
    lines.where('credit <> ?', 0).first
  end


  # TODO ici mettre un alias avec debit_locked?
  def debit_editable?
    !line_debit.locked?
  end

  # TODO ici mettre un alias avec debit_locked?
  def credit_editable?
    !line_credit.locked?
  end


  # inidque si le transfer peut être détruit en vérifiant qu'aucune ligne n'a été verrouillée
  def destroyable?
    lines.select {|l| l.locked? }.empty?
  end

  # pour indiquer que l'on ne peut modifier le compte de donneur
  def debit_locked?
    line_debit ? line_debit.locked : false
  end

  # pour indiquer que l'on ne peut modifier le compte receveur
  def credit_locked?
    line_credit ? line_credit.locked : false
  end
  
  # utile pour savoir que l'on ne peut toucher aux rubriques montant, narration 
  # et date
  def partial_locked?
    credit_locked? || debit_locked?
  end

 private

  # callback appelé par before_destroy pour empêcher la destruction des lignes
  # et du transfer si une ligne est verrouillée
  def should_be_destroyable
    return self.destroyable?
  end

 # retourne l'id du journal d'OD correspondant à l'organisme dont dépent transfer
 # 
 # utilisée par build_debit_line et build_credit_line pour construire les lignes
  def od_id
   self.organism.od_books.first.id
 end

 # build_debit_line construit la ligne d'écriture débitrice correspondant au 
 # virement
  def build_line_debit
    cash_id = bank_account_id = nil
    if debitable_type == 'Cash'
      cash_id = debitable_id
      bank_account_id = nil
    elsif debitable_type == 'BankAccount'
      bank_account_id = debitable_id
      cash_id = nil
    end
    lines.build(:line_date=> date, :narration=>narration, :credit=> 0,
      :debit=>amount, :cash_id=> cash_id, :bank_account_id=> bank_account_id , 
     :book_id=>od_id)
  end
  
  # build_credit_line construit la ligne d'écriture créditrice à partir d'un
  # virement
  def build_line_credit
    cash_id = bank_account_id = nil
    if creditable_type == 'Cash'
      cash_id = creditable_id
      bank_account_id = nil
    elsif creditable_type == 'BankAccount'
      bank_account_id = creditable_id
      cash_id = nil
    end
    lines.new(:line_date=> date, :narration=>narration, :credit=>amount,
      :debit=>0, :cash_id=> cash_id, :bank_account_id=> bank_account_id,
    :book_id=>od_id)
  end

  # appelé par after_update
  def update_line_debit
   
    cash_id = bank_account_id = nil
    if debitable_type == 'Cash'
      cash_id = debitable_id
      bank_account_id = nil
    elsif debitable_type == 'BankAccount'
      bank_account_id = debitable_id
      cash_id = nil
    end
    
    l=line_debit
    l.cash_id = cash_id
    l.bank_account_id = bank_account_id
    l.save!(:validate => false)
    
  end

  # appelé par after_update
  def update_line_credit
     cash_id = bank_account_id = nil
    if creditable_type == 'Cash'
      cash_id = creditable_id
      bank_account_id = nil
    elsif creditable_type == 'BankAccount'
      bank_account_id = creditable_id
      cash_id = nil
    end

    l=line_credit
    l.cash_id = cash_id
    l.bank_account_id = bank_account_id
    l.save!(:validate => false)
  end

  

  # applé par after create; validate => false car ces lignes n'ont pas de nature
  # ni de mode de payment
  # TODO voir s'il ne faut pas passer par une STI pour line avec des validates
  # conditionnels pour éviter cette manoeuvre dangereuse.
  # Normalement, puisque le transfer est valide (car on est après un after_create
  # il ne devrait pas y avoir de problème particulier
  def create_lines
    build_line_debit.save!
    build_line_credit.save!
  end



  

  def amount_cant_be_null
    errors.add :amount, 'nul !' if amount == 0
  end

  def required_fill_debitable
    errors.add :fill_debitable, 'champ obligatoire' if (debitable_id == nil || debitable_type == nil)
  end

  def required_fill_creditable
    errors.add :fill_creditable, 'champ obligatoire' if (creditable_id == nil || creditable_type == nil)
  end

  def different_debit_and_credit
    if fill_debitable == fill_creditable
      errors.add :fill_debitable, 'identiques !'
      errors.add :fill_creditable, 'identiques !'
    end
  end





end
