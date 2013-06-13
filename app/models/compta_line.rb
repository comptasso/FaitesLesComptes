# -*- encoding : utf-8 -*-

class ComptaLine < ActiveRecord::Base

 # belongs_to :book
  belongs_to :destination
  belongs_to :nature
  belongs_to :account
  belongs_to :check_deposit
  
  # les lignes appartiennent à un writing
  belongs_to :writing
  has_and_belongs_to_many :bank_extract_lines,
    :join_table=>:bank_extract_lines_lines,
    :foreign_key=>'line_id',
    :uniq=>true # pour les rapprochements bancaires

  attr_accessible :debit, :credit, :writing_id, :account_id, 
    :nature, :nature_id, :destination_id, :check_number, :payment_mode, :check_deposit_id

  # La présence est assurée par la valeur par défaut
  # mais on laisse presence:true, ne serait-ce que parce que cela permet d'avoir l'*
  # dans le formulaire
  validates :debit, :credit, presence:true, numericality:true, :not_null_amounts=>true, :not_both_amounts=>true, two_decimals:true  # format: {with: /^-?\d*(.\d{0,2})?$/}

  # impose d'avoir une nature s'il n'y a pas de compte
  validates :nature_id, presence: true, :unless => lambda { self.account_id || self.account }

  # les natures et les comptes doivent être cohérents avec l'exercice
  validates :nature_id, :account_id, :belongs_to_period=>true
   
  # TODO faire les tests
  validates :nature_id, :destination_id, :debit, :credit, :created_at, :payment_mode, :cant_edit=>true, :if=>Proc.new {|r| r.locked? }
  

  before_save  :fill_account, :if=> lambda {nature && nature.account}
  before_destroy :not_locked

  scope :in_out_lines, where('nature_id IS NOT ?', nil)
  scope :with_writings, joins(:writing)
  scope :with_writing_and_book, joins(:writing=>:book)
  scope :without_AN , where('books.title != ?', 'AN')
  # ces scope n'inclut pas with_writings, ce qui veut dire qu'il faut que cela soit fait par
  # ailleurs, c'est notamment le cas lorsqu'on passe par book car book has_many :compta_lines, :through=>:writings
  scope :mois, lambda { |date| where('date >= ? AND date <= ?', date.beginning_of_month, date.end_of_month) }
  # extract est comme range_date mais n'inclut pas with_writings
  scope :extract, lambda {|from, to| where('writings.date >= ? AND writings.date <= ?', from, to ).order('date')}
  # inclut with_writings et donc doit être utilisé pour un query qui ne l'inclut pas déja.
  scope :mois_with_writings, lambda {|date| with_writings.where('date >= ? AND date <= ?', date.beginning_of_month, date.end_of_month)}

  scope :range_date, lambda {|from, to| with_writings.extract(from, to).order('date')}
  scope :listing, lambda {|from, to| with_writing_and_book.where('books.title != ?', 'AN').where('date >= ? AND date <= ?', from, to ).order('date')}
  scope :before_including_day, lambda {|d| with_writings.where('date <= ?',d)}
  scope :unlocked, where('locked = ?', false)
  scope :locked, where('locked = ?', true)
  scope :classe, lambda {|n| where('number LIKE ?', "#{n}%").order('number ASC')}

  # trouve tous les chèques en attente d'encaissement à partir des comptes de chèques à l'encaissement
  # et du champ check_deposit_id
  scope :pending_checks, lambda { where(:account_id=>Account.rem_check_accounts.map {|a| a.id}, :check_deposit_id => nil).order('id') }

  # renvoie les lignes non pointées (appelé par BankAccount qui a des compta_lines, :through=>:accounts)
  scope :not_pointed, joins(:writing).where("NOT EXISTS (SELECT * FROM BANK_EXTRACT_LINES_LINES WHERE LINE_ID = COMPTA_LINES.ID)").order('writings.date')

  delegate :date, :narration, :ref, :book, :support, :lock, :to=>:writing

  def nature_name
    nature ? nature.name : ''
  end

  def destination_name
    destination ? destination.name : ''
  end

  def siblings
    writing.compta_lines
  end

  # répond à la question si une ligne est affectée à un extrait bancaire ou non.
  def pointed?
    support_line = writing.support_line
    support_line.check_deposit_id || support_line.bank_extract_lines.any?
  end


  def editable?
    !(pointed? || locked?)
  end

      # méthode utilisée pour la remise des chèques (pour afficher les chèques dans la zone de sélection)
      def label
        "#{I18n.l date, :format=>'%d-%m'} - #{narration} - #{format('%.2f',debit)}"
      end

  protected

  # remplit le champ account_id avec celui associé à nature si nature est effectivement associée à un compte.
  def fill_account
    self.account_id = nature.account.id
  end

  def not_locked
    !locked
  end

 

end
