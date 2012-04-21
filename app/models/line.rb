# -*- encoding : utf-8 -*-

class Line < ActiveRecord::Base
  # apporte la validation
  # TODO à retirer
  include Validations

  PAYMENT_MODES ||= %w(CB Chèque Espèces Prélèvement Virement)
  BANK_PAYMENT_MODES ||= %w(CB Chèque Prélèvement Virement)

  before_destroy :cant_change_if_locked

  belongs_to :book
  belongs_to :destination
  belongs_to :nature
  belongs_to :bank_extract
  belongs_to :check_deposit
  belongs_to :bank_account
  belongs_to :cash
  belongs_to :owner, :polymorphic=>true
  has_one :bank_extract_line


  before_validation :sold_debit_credit # une ligne ne peut avoir debit et credit simultanément
  # TODO voir pour remplacer les champ par amount et boolean et faire des virtual attributes

  # pour interdire qu'une ligne ait un debit et un credit rempli.
  # FIXME : faire plutôt un validator qui crée une erreur sur ce cas de figure de toute façon anormal
  # et un autre pour éviter les doubles zeros
  def sold_debit_credit
    # ici il faudrait plutôt mettre à zero tout ce qui n'est pas un nombre
    self.debit ||= 0.0
    self.credit ||= 0.0
    if self.credit > self.debit
      self.credit= self.credit-self.debit; self.debit =0
    else
      self.debit= self.debit-self.credit; self.credit = 0
    end
  end

  validates :debit, :credit, numericality: true, format: {with: /^-?\d*(.\d{0,2})?$/}
  validates :line_date, presence: true, must_belong_to_period: true
  validates :nature_id, presence: true
  validates :narration, presence: true
  validates :payment_mode, presence: true,  :inclusion => { :in =>PAYMENT_MODES ,
    :message => "valeur inconnue" }
  validates_with NotNullAmount
  validates :credit, presence: true # du fait du before validate, ces deux champs sont toujours remplis
  validates :debit, presence: true # ces validates n'ont pour objet que de mettre un * dans le formulaire
 
  # FIXME
  #  validates :narration, :line_date, :nature_id, :destination_id, :debit, :credit, :book_id, :created_at, :payment_mode, :cant_edit=>true if :locked?

  before_save :check_bank_and_cash_ids

  default_scope order: 'line_date ASC'

  scope :mois, lambda { |date| where('line_date >= ? AND line_date <= ?', date.beginning_of_month, date.end_of_month) }
  scope :multiple, lambda {|copied_id| where('copied_id = ?', copied_id)}
 
  scope :not_checks_received, where('payment_mode != ? OR credit <= 0', 'Chèque')

  scope :checks_received, where('payment_mode = ? AND credit > 0', 'Chèque')
  
  scope :non_depose, checks_received.where('check_deposit_id IS NULL')
  scope :period, lambda {|p| where('line_date >= ? AND line_date <= ?', p.start_date, p.close_date)}
  scope :period_month, lambda {|p,m| where('line_date >= ? AND line_date <= ?', p.start_date.months_since(m), p.start_date.months_since(m).end_of_month) }
  scope :cumul_period_month, lambda {|p,m| where('line_date >= ? AND line_date <=?', p.start_date, p.start_date.months_since(m).end_of_month)}

  # TODO voir si ce scope est encore utilisé
  scope :month, lambda {|month_year| where('line_date >= ? AND line_date <= ?',
      Date.civil(month_year[/\d{4}$/].to_i, month_year[/^\d{2}/].to_i,1),
      Date.civil(month_year[/\d{4}$/].to_i, month_year[/^\d{2}/].to_i,1).end_of_month    )}

  # FIXME Ces fonctions de classe semblent marcher avec un arel.
  # néanmoins, elles pourraient être perturbantes si on ne filtre pas assez bien en amont les lignes que l'on veut.
  def self.solde_debit_avant(date)
    Line.where('line_date < ?', date).sum(:debit)
  end

  def self.solde_credit_avant(date)
    Line.where('line_date < ?', date).sum(:credit)
  end

  # # monthly sold donne le solde d'un mois fourni au format mm-yyyy
  # FIXME va poser des problèmes avec plusieurs organismes
  def self.monthly_sold(month)
    lines = Line.month(month)
    lines.sum(:credit) - lines.sum(:debit)
  end
  
  def pick_date
    line_date ? (I18n::l line_date) : nil
  end

  def pick_date=(string)
    s = string.split('/')
    self.line_date = Date.civil(*s.reverse.map{|e| e.to_i})
  rescue ArgumentError
    self.errors[:line_date] << 'Date invalide'
    nil
  end
  






#  def multiple_info
#    if self.multiple
#      # on veut avoir le nombre
#      t= Line.multiple(self.copied_id)
#      { nombre: t.size, first_date: t.first.line_date,
#        last_date: t.last.line_date,
#        narration: self.narration,
#        destination: self.destination_name,
#        nature: self.nature_name,
#        debit: self.debit,
#        credit: self.credit,
#        total: t.sum(:debit)+ t.sum(:credit),
#        copied_id: self.copied_id
#      }
#    end
#  end
#
#
#
#  def repete(number, period)
#    d=self.line_date
#    self.multiple=true
#    self.copied_id=self.id
#    t=[self]
#    number.times do |i|
#      case period
#      when 'Semaines' then new_date = d+(i+1)*7
#      when 'Mois' then new_date= d.months_since(i+1)
#      when 'Trimestres' then new_date=d.months_since(3*(i+1))
#      end
#      t << self.copy(new_date)
#    end
#    t.each { |l| l.save}
#    return t.size
#  rescue
#    self.multiple=false
#  end

  
  # crée une ligne à partir d'une ligne existante en changeant la date
  def copy(new_date)
    l= self.dup
    l.line_date=new_date
    l
  end

  # répond à la question si une ligne est affectée à un extrait bancaire ou non.
  def pointed?
    self.bank_extract_id
  end

  def to_csv
    [I18n::l(self.line_date), self.narration, "#{self.destination_name}",
      "#{self.nature_name}",
      self.debit.to_f, self.credit.to_f, "#{self.payment_mode}"]
  end


  # méthode utilisée pour la remise des chèques (pour afficher les chèques dans la zone de sélection)
  def check_for_select
  "#{I18n.l line_date, :format=>'%d-%m'} - #{narration} - #{format('%.2f',credit)}"
  end

  protected

  
  def destination_name
    self.destination ? self.destination.name : 'non indiqué'
  end

  def nature_name
    self.nature ? self.nature.name : 'non indiqué'
  end

  # Si le paiement est Especes, mettre à nil le bank_account_id
  # Autrement mettre à nil le cash_id
  # si le paiement est en chèque et que bank_extract n'est pas rempli alors mettre à nil le bank_account_id
  def check_bank_and_cash_ids
 
  # TODO probablement des classes lines héritées faciliteraient la chose.
    Rails.logger.debug 'modfication des bank et cash ids'
    if self.nature  # ceci permet de ne pas faire ce contrôle pour les virements qui n'ont pas de nature
        self.bank_account_id = nil if self.payment_mode == 'Espèces'
        self.cash_id = nil unless self.payment_mode =='Espèces'
    end
 
  end

  def cant_change_if_locked
    !locked
  end


  
end
