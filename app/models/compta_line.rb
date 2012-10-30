# -*- encoding : utf-8 -*-

class ComptaLine < ActiveRecord::Base

  belongs_to :book
  belongs_to :destination
  belongs_to :nature
  belongs_to :account
  belongs_to :counter_account, :class_name=>'Account'
  belongs_to :bank_extract
  belongs_to :check_deposit
  belongs_to :bank_account

  # les lignes appartiennent à un writing
  belongs_to :writing
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
  scope :with_writings, joins(:writing)
  scope :with_writing_and_book, joins(:writing=>:book)
  scope :without_AN , where('books.title != ?', 'AN')
  # ce scope n'inclut pas with_writings, ce qui veut dire qu'il faut que cela soit fait par
  # ailleurs, c'est notamment le cas lorsqu'on passe par book car book has_many :compta_lines, :through=>:writings
  scope :mois, lambda { |date| where('date >= ? AND date <= ?', date.beginning_of_month, date.end_of_month) }
  # inclut with_writings et donc doit être utilisé pour un query qui ne l'inclut pas déja.
  scope :mois_with_writings, lambda {|date| with_writings.where('date >= ? AND date <= ?', date.beginning_of_month, date.end_of_month)}

  scope :range_date, lambda {|from, to| with_writings.where('date >= ? AND date <= ?', from, to ).order('date')}
  scope :listing, lambda {|from, to| with_writing_and_book.where('books.title != ?', 'AN').where('date >= ? AND date <= ?', from, to ).order('date')}
  scope :before_including_day, lambda {|d| with_writings.where('date <= ?',d)}
  scope :unlocked, where('locked = ?', false)
  scope :classe, lambda {|n| where('number LIKE ?', "#{n}%").order('number ASC')}

  # trouve tous les chèques en attente d'encaissement à partir des comptes de chèques à l'encaissement
  # et du champ check_deposit_id
  scope :pending_checks, lambda { where(:account_id=>Account.rem_check_accounts.map {|a| a.id}, :check_deposit_id => nil) }

  delegate :date, :narration, :ref, :book, :support, :lock, :to=>:writing

  # transforme ComptaLine en un Line, utile pour les tests
  # églement utilisé dans le modèle CheckDeposit pour accéder indifférement aux compta_lines
  # et aux lines (sans avoir une erreur TypeMislatch).
#  def to_line
#    if persisted?
#      Line.find(id)
#    else
#      Line.new(attributes)
#    end
#  end

  def siblings
    writing.compta_lines
  end

  # répond à la question si une ligne est affectée à un extrait bancaire ou non.
  def pointed?
    supportline = writing.supportline
    supportline.check_deposit_id || supportline.bank_extract_lines.any?
  end


  def editable?
    !(pointed? || locked?)
  end

   # méthode utilisée pour la remise des chèques (pour afficher les chèques dans la zone de sélection)
  def check_for_select
    "#{I18n.l date, :format=>'%d-%m'} - #{narration} - #{format('%.2f',debit)}"
  end


  protected

  # remplit le champ account_id avec celui associé à nature si nature est effectivement associée à un compte.
  def fill_account
    self.account_id = nature.account.id
  end

 

end
