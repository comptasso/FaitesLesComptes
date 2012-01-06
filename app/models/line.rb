# -*- encoding : utf-8 -*-

class Line < ActiveRecord::Base
  belongs_to :book
  belongs_to :destination
  belongs_to :nature
  belongs_to :bank_extract
  belongs_to :bank_deposit
  belongs_to :bank_account
  belongs_to :cash
  has_one :bank_extract_line

  validates :debit, :credit, numericality: true
  validates :line_date, presence: true

  PAYMENT_MODES= %w(CB Chèque Espèces Prélèvement Virement)
  BANK_PAYMENT_MODES = %w(CB Chèque Prélèvement Virement)

  before_save :check_bank_and_cash_ids

  # Si le paiement est Especes, mettre à nil le bank_account_id
  # Autrement mettre à nil le cash_id
  # si le paiement est en chèque et que bank_extract n'est pas rempli alors mettre à nil le bank_account_id
  def check_bank_and_cash_ids
    self.bank_account_id = nil if self.payment_mode == 'Espèces'
    self.cash_id = nil unless self.payment_mode =='Espèces'
    self.bank_account_id = nil if self.credit > 0.001 && self.payment_mode == 'Chèque' && self.bank_extract_id.nil?
  end
 

  default_scope order: 'line_date ASC'

  scope :mois, lambda { |date| where('line_date >= ? AND line_date <= ?', date.beginning_of_month, date.end_of_month) }
  scope :multiple, lambda {|copied_id| where('copied_id = ?', copied_id)}
 
 scope :not_checks_received, where('payment_mode != ? OR credit <= 0', 'Chèque')
# scope :not_pointed,
  scope :checks_received, where('payment_mode = ? AND credit > 0', 'Chèque')
  
  scope :non_depose, checks_received.where('check_deposit_id IS NULL')
  scope :period, lambda {|p| where('line_date >= ? AND line_date <= ?', p.start_date, p.close_date)}
  scope :period_month, lambda {|p,m| where('line_date >= ? AND line_date <= ?', p.start_date.months_since(m), p.close_date.months_since(m).end_of_month) }
  scope :cumul_period_month, lambda {|p,m| where('line_date >= ? AND line_date <=?', p.start_date, p.start_date.months_since(m).end_of_month)}




  def self.solde_debit_avant(date)
    Line.where('line_date < ?', date).sum(:debit)
  end

  def self.solde_credit_avant(date)
    Line.where('line_date < ?', date).sum(:credit)
  end

  def multiple_info
    if self.multiple
      # on veut avoir le nombre
      t= Line.multiple(self.copied_id)
      { nombre: t.size, first_date: t.first.line_date,
        last_date: t.last.line_date,
        narration: self.narration,
        destination: self.destination_name,
        nature: self.nature_name,
        debit: self.debit,
        credit: self.credit,
        total: t.sum(:debit)+ t.sum(:credit),
        copied_id: self.copied_id
      }
    end
  end



  def repete(number, period)
    d=self.line_date
    self.multiple=true
    self.copied_id=self.id
    t=[self]
    number.times do |i|
      case period
      when 'Semaines' then new_date = d+(i+1)*7
      when 'Mois' then new_date= d.months_since(i+1)
      when 'Trimestres' then new_date=d.months_since(3*(i+1))
      end
      t << self.copy(new_date)
    end
    t.each { |l| l.save}
    return t.size
  rescue
    self.multiple=false
  end

  
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
  

  # before_validation :default_debit_credit
  #
  #
  #
  #  private
  #
  #  def default_debit_credit
  #    # ici il faudrait plutôt mettre à zero tout ce qui n'est pas un nombre
  #    debit ||= 0.0
  #    credit ||= 0.0
  #  end

  protected

  
  def destination_name
    self.destination ? self.destination.name : 'non indiqué'
  end

  def nature_name
    self.nature ? self.nature.name : 'non indiqué'
  end

  
end
