# -*- encoding : utf-8 -*-

class ComptaLine < ActiveRecord::Base

  # belongs_to :book
  belongs_to :destination
  belongs_to :nature
  belongs_to :account
  belongs_to :check_deposit
  
  # les lignes appartiennent à un writing
  belongs_to :writing
  has_one :bank_extract_line

#  attr_accessible :debit, :credit, :writing_id, :account_id, 
#    :nature, :nature_id, :destination_id, 
#    :check_number, :payment_mode, :check_deposit_id

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
  # validates :account_id, :cant_edit=>true, :if=>"pointed?" 

  before_save  :fill_account, :if=> lambda {nature && nature.account}
  before_destroy :not_locked

  scope :in_out_lines, -> {where('nature_id IS NOT ?', nil)}
  scope :with_writings, -> {joins(:writing)}
  scope :with_writing_and_book, -> {joins(:writing=>:book)}
  scope :without_AN , -> {where('books.abbreviation != ?', 'AN')}
  # ces scope n'inclut pas with_writings, ce qui veut dire qu'il faut que cela soit fait par
  # ailleurs, c'est notamment le cas lorsqu'on passe par book car book has_many :compta_lines, :through=>:writings
  scope :mois, lambda { |date| where('date >= ? AND date <= ?', date.beginning_of_month, date.end_of_month) }
  # inclut with_writings et donc doit être utilisé pour un query qui ne l'inclut pas déja.
  scope :mois_with_writings, lambda {|date| with_writings.where('date >= ? AND date <= ?', date.beginning_of_month, date.end_of_month)}

  scope :range_date, lambda {|from, to| with_writings.extract(from, to)}
  # extract est comme range_date mais n'inclut pas with_writings
  scope :extract, lambda {|from, to| where('writings.date >= ? AND writings.date <= ?', from, to ).order('writings.date')}
  
  
  scope :listing, lambda {|from, to| with_writing_and_book.where('books.abbreviation != ?', 'AN').where('date >= ? AND date <= ?', from, to ).order('date')}
  scope :before_including_day, lambda {|d| with_writings.where('date <= ?',d)}
  scope :unlocked, -> {where('locked = ?', false)}
  scope :definitive, -> {where('locked = ?', true)} # remplacé le nom du scope locked par definitive car
  # engendrait un conflit avec les arel de Rails
  scope :classe, lambda {|n| where('number LIKE ?', "#{n}%").order('number ASC')} 

  # trouve tous les chèques en attente d'encaissement à partir des comptes de chèques à l'encaissement
  # et du champ check_deposit_id
  scope :sectored_pending_checks, lambda { |sector| includes(:writing=>:book).
      where('books.sector_id'=>sector.id, :account_id=>Account.rem_check_accounts.map {|a| a.id},
      :check_deposit_id => nil).order('compta_lines.id') }
  scope :pending_checks, lambda { where(:account_id=>Account.rem_check_accounts.map {|a| a.id}, :check_deposit_id => nil).order('id') }
  
  # renvoie les lignes non pointées (appelé par BankExtract), ce qui ne prend pas en compte le journal A nouveau
  scope :not_pointed, -> {
    includes(:writing).
    joins(:writing=>:book).
    where("(books.abbreviation != 'AN') AND NOT EXISTS (SELECT * FROM BANK_EXTRACT_LINES WHERE COMPTA_LINE_ID = COMPTA_LINES.ID)").
    order('writings.date')}

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
    bank_extract_line
  end

  # une compta line est editable si elle est ni pointée, ni verrouillée, ni associée à une remise de chèque
  def editable?
    !(pointed? || locked? || deposited?)
  end
  
  # une compta line est associée à une remise de chèque dès lors que son champ check_deposit_id
  # est différent de nil
  def deposited?
    check_deposit_id
  end

  # méthode utilisée pour la remise des chèques (pour afficher les chèques dans la zone de sélection)
  def label
    "#{I18n.l date, :format=>'%d-%m'} - #{narration} - #{format('%.2f',debit)}"
  end
  
  # méthode utilisée dans l'édition des livres dans la partie compta.
  # Une méthode similaire existe pour ComptaLine, ce qui permet d'avoir
  # indifféremment des lignes de type Writing et ComptaLine dans la collection
  # 
  # Attention, un changement du nombre de colonne doit être fait sur les 
  # deux méthodes.
  def to_pdf
    [account.number, account.title, 
      ActionController::Base.helpers.number_with_precision(debit, :precision=>2),
      ActionController::Base.helpers.number_with_precision(credit, :precision=>2)]
  end
  
  
  protected
  
  # utilisé par Writing dans une Transaction pour verrouiller ses compta_lines
  # Quand une compta_line est une remise de chèque, l'action verrouille également
  # les chèques associés.
  # 
  # Ne devrait pas être appelé directement. 
  def verrouillage
    unless locked?
      update_attribute(:locked, true)
      if check_deposit_id
        cd = check_deposit
        cd.checks.each {|l| l.lock}
      end
    end
  end

  

  # remplit le champ account_id avec celui associé à nature si nature est effectivement associée à un compte.
  # appelé par before save
  def fill_account
    self.account_id = nature.account.id
  end

  # appelé par before_destrou
  def not_locked
    !locked
  end

 

end
