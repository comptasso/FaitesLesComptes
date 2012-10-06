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
#  belongs_to :cash
  belongs_to :owner, :polymorphic=>true  # pour les transferts uniquement (à ce stade)
  has_and_belongs_to_many :bank_extract_lines,
    :join_table=>:bank_extract_lines_lines,
    :foreign_key=>'line_id',
    :uniq=>true # pour les rapprochements bancaires

  # voir au besoin les validators qui sont dans lib/validators
  validates :debit, :credit, numericality: true, two_decimals:true  # format: {with: /^-?\d*(.\d{0,2})?$/}
  validates :book_id, presence:true
  validates :line_date, presence: true
  validates :line_date, must_belong_to_period: true
  validates :nature_id, presence: true, :unless => lambda { self.account_id || self.account }
  validates :narration, presence: true
  validates :debit, :credit, :not_null_amounts=>true, :not_both_amounts=>true
  validates :credit, presence: true # du fait du before validate, ces deux champs sont toujours remplis
  validates :debit, presence: true # ces validates n'ont pour objet que de mettre un * dans le formulaire
  # TODO faire les tests
  validates :narration, :line_date, :nature_id, :destination_id, :debit, :credit, :book_id, :created_at, :payment_mode, :cant_edit_if_locked=>true

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

end
