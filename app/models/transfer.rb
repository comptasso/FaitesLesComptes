# coding: utf-8

class Transfer < ActiveRecord::Base
  include Utilities::PickDateExtension

  before_destroy :should_be_destroyable 

  belongs_to :organism
  # ceci est un compte
  belongs_to :to_account, class_name:'Account'
  belongs_to :from_account, class_name:'Account'

  # ce qui veut dire que Line a un champ owner_id qui permet de faire le lien avec le transfer
  # Line de son côté a belongs_to owner, polymorphic:true
  has_many  :lines, :as=>:owner, :dependent=>:destroy

  alias children lines
  

  validates :date, :amount, :presence=>true 
  validates :to_account_id, :presence=>true
  validates :from_account_id, :presence=>true
  validates :amount, numericality: true
  validate :amount_cant_be_null
  validate :different_debit_and_credit

  after_create :create_lines
  after_update :update_line_from, :unless=>lambda { self.line_from.locked }
  after_update :update_line_to, :unless=>lambda { self.line_to.locked }

  # cf pick_date_extension
  pick_date_for :date

  
  def line_to
    ComptaLine.where('owner_id = ? AND owner_type = ? AND debit <> ? ',id, 'Transfer', 0).first
  end

  def line_from
    ComptaLine.where('owner_id = ? AND owner_type = ? AND credit <> ? ',id,'Transfer', 0).first
  end


  # TODO ici mettre un alias avec debit_locked?
  def to_editable?
    !line_to.locked?
  end

  # TODO ici mettre un alias avec debit_locked?
  def from_editable?
    !line_from.locked?
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
 
  # callback appelé par before_destroy pour empêcher la destruction des lignes
  # et du transfer si une ligne est verrouillée
  def should_be_destroyable
    return self.destroyable?
  end

  # applé par after create, crée une ligne dans chacun des livres
  # de caisse et/ou de banque qui font l'objet du virement.
  def create_lines
    b_id = OdBook.find(:first)
    l = ComptaLine.new(:line_date=> date, :narration=>narration, :debit=> amount,
      :credit=>0, :account_id=> to_account_id,
      :book_id=>b_id,  owner_id:self.id, owner_type:'Transfer')
    unless l.valid?
      puts l.inspect
      puts l.errors.messages
    end
    l.save
    
    l =  ComptaLine.new(:line_date=> date, :narration=>narration, :credit=>amount,
      :debit=>0, :account_id=> from_account_id,
      :book_id=>b_id, owner_id:self.id, owner_type:'Transfer')
    unless l.valid?
      puts l.inspect
      puts l.errors.messages
    end
    l.save
  end

  # appelé par after_update pour mettre à jour le compte bancaire et le livre associé
  def update_line_from
    line_from.update_attributes(:account_id=> from_account_id)
  end

  # appelé par after_update
  def update_line_to
    line_to.update_attributes(:account_id=> to_account_id)
  end

  # validations
  def amount_cant_be_null
    errors.add :amount, 'nul !' if amount == 0
  end

  def different_debit_and_credit
    if to_account_id == from_account_id
      errors.add :fill_to_account, 'identiques !'
      errors.add :fill_from_account, 'identiques !'
    end
  end

end
