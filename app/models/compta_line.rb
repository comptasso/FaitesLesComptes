# -*- encoding : utf-8 -*-

class ComptaLine < ActiveRecord::Base

  self.table_name = 'Lines'
  
  belongs_to :book
  belongs_to :destination
  belongs_to :nature
  belongs_to :account
  belongs_to :counter_account, :class_name=>'Account'
  belongs_to :bank_extract
  belongs_to :check_deposit
  belongs_to :bank_account

  # les lignes appartiennent à un owner qui peut être un transfer ou un writing
  belongs_to :owner, :polymorphic=>true  
  has_and_belongs_to_many :bank_extract_lines,
    :join_table=>:bank_extract_lines_lines,
    :foreign_key=>'line_id',
    :uniq=>true # pour les rapprochements bancaires

  # voir au besoin les validators qui sont dans lib/validators
  validates :debit, :credit, numericality: true, two_decimals:true  # format: {with: /^-?\d*(.\d{0,2})?$/}
#  validates :book_id, presence:true
#  validates :line_date, presence: true
#  validates :line_date, must_belong_to_period: true
  validates :nature_id, presence: true, :unless => lambda { self.account_id || self.account }
#  validates :narration, presence: true
  validates :debit, :credit, :not_null_amounts=>true, :not_both_amounts=>true
  validates :credit, presence: true # du fait du before validate, ces deux champs sont toujours remplis
  validates :debit, presence: true # ces validates n'ont pour objet que de mettre un * dans le formulaire
  # TODO faire les tests
  validates :nature_id, :destination_id, :debit, :credit, :created_at, :payment_mode, :cant_edit_if_locked=>true

  before_save  :fill_account, :if=> lambda {nature && nature.account}

  scope :in_out_lines, where('nature_id IS NOT ?', nil)
  scope :with_writings, joins("INNER JOIN writings ON writings.id = owner_id")
  scope :mois, lambda { |date| with_writings.where('date >= ? AND date <= ?', date.beginning_of_month, date.end_of_month) }
  scope :range_date, lambda {|from, to| with_writings.where('date >= ? AND date <= ?', from, to )}


  # trouve tous les chèques en attente d'encaissement à partir des comptes de chèques à l'encaissement
  # et du champ check_deposit_id
  scope :pending_checks, lambda { where(:account_id=>Account.rem_check_accounts.map {|a| a.id}, :check_deposit_id => nil) }

  delegate :date, :narration, :ref, :book, :support, :lock, :to=>:owner

  # transforme ComptaLine en un Line, utile pour les tests
  # églement utilisé dans le modèle CheckDeposit pour accéder indifférement aux compta_lines
  # et aux lines (sans avoir une erreur TypeMislatch).
  def to_line
    if persisted?
      Line.find(id)
    else
      Line.new(attributes)
    end
  end

  def siblings
    owner.compta_lines
  end

  # répond à la question si une ligne est affectée à un extrait bancaire ou non.
  def pointed?
    supportline = owner.counter_line
    supportline.check_deposit_id || supportline.bank_extract_lines.any?
  end


  def editable?
    !(pointed? || locked?)
  end

  protected

  # remplit le champ account_id avec celui associé à nature si nature est effectivement associée à un compte.
  def fill_account
    self.account_id = nature.account.id
  end

 

end
