# coding: utf-8

class Transfer < ActiveRecord::Base
  include Utilities::PickDateExtension

 

  before_destroy :should_be_destroyable

  belongs_to :organism
  # ceci est un compte
  belongs_to :debitable, class_name:'Account'
  belongs_to :creditable, class_name:'Account'

  # ce qui veut dire que Line a un champ owner_id qui permet de faire le lien avec le transfer
  # Line de son côté a belongs_to owner, polymorphic:true
  has_many   :lines, :as=>:owner, :dependent=>:destroy

  validates :date, :amount, :presence=>true
  validates :debitable_id, :presence=>true
  validates :creditable_id, :presence=>true
  validates :amount, numericality: true
  validate :amount_cant_be_null
  validate :different_debit_and_credit

  after_create :create_lines
  after_update :update_line_debit, :unless=>lambda { self.line_debit.locked }
  after_update :update_line_credit, :unless=>lambda { self.line_credit.locked }

  # cf pick_date_extension
  pick_date_for :date

  # remplit les champs debitable_type et _id avec les parties 
  # model et id de l'argument.
  

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
    self.lines.select {|l| l.locked? }.empty?
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
 
  # helper
  
 

  # callbacks

  # callback appelé par before_destroy pour empêcher la destruction des lignes
  # et du transfer si une ligne est verrouillée
  def should_be_destroyable
    return self.destroyable?
  end


  # applé par after create, crée une ligne dans chacun des livres
  # de caisse et/ou de banque qui font l'objet du virement.
  def create_lines
    b_id = Account.find_by_id(debitable_id).accountable.book.id
    l = lines.new(:line_date=> date, :narration=>narration, :credit=> amount,
      :debit=>0, :account_id=> debitable_id,
      :book_id=>b_id)
    unless l.valid?
      logger.warn l.inspect
      logger.warn l.errors.messages
    end
    l.save
    b_id = Account.find_by_id(creditable_id).accountable.book.id
    l =  lines.create!(:line_date=> date, :narration=>narration, :credit=>0,
      :debit=>amount, :account_id=> creditable_id,
      :book_id=>b_id)
    unless l.valid?
      logger.warn l.inspect
      logger.warn l.errors.messages
    end
    l.save
  end

  # appelé par after_update pour mettre à jour counter_account
  # TODO faire le update
  def update_line_credit
    line_credit.update_attribute(:account_id, creditable_id)

  end

  # appelé par after_update
  def update_line_debit
    line_debit.update_attribute(:account_id, debitable_id)
  end


  # validations
  def amount_cant_be_null
    errors.add :amount, 'nul !' if amount == 0
  end


  def different_debit_and_credit
    if debitable_id == creditable_id
      errors.add :fill_debitable, 'identiques !'
      errors.add :fill_creditable, 'identiques !'
    end
  end





end
