# -*- encoding : utf-8 -*-

class Line < ActiveRecord::Base
  include Utilities::PickDateExtension # apporte les méthodes pick_date_for
  
  

  

  belongs_to :book 
  belongs_to :destination
  belongs_to :nature
  belongs_to :bank_extract
  belongs_to :check_deposit
  belongs_to :bank_account
  belongs_to :cash
  belongs_to :owner, :polymorphic=>true  # pour les transferts uniquement (à ce stade)
  has_and_belongs_to_many :bank_extract_lines, :uniq=>true 

  pick_date_for :line_date 
  
  before_save :check_bank_and_cash_ids
  before_destroy :cant_change_if_locked

  # voir au besoin les validators qui sont dans lib/validators
  validates :debit, :credit, numericality: true, two_decimals:true  # format: {with: /^-?\d*(.\d{0,2})?$/}
  validates :book_id, presence:true
  validates :line_date, presence: true
  validates :line_date, must_belong_to_period: true
  validates :nature_id, presence: true, :unless=> lambda {self.owner_type == 'Transfer'}
  validates :narration, presence: true
  validates :payment_mode, presence: true,  :inclusion => { :in =>PAYMENT_MODES ,
    :message => "valeur inconnue" }, :unless=>lambda { self.owner_type == 'Transfer'}
  validates :debit, :credit, :not_null_amounts=>true, :not_both_amounts=>true
  validates :credit, presence: true # du fait du before validate, ces deux champs sont toujours remplis
  validates :debit, presence: true # ces validates n'ont pour objet que de mettre un * dans le formulaire
  # TODO faire les tests
  validates :narration, :line_date, :nature_id, :destination_id, :debit, :credit, :book_id, :created_at, :payment_mode, :cant_edit_if_locked=>true

  # LES SCOPES
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

  scope :monthyear, lambda {|my| where('line_date >= ? AND line_date <= ?',
     my.beginning_of_month, my.end_of_month  )}
  scope :range_date, lambda { |fd,td| where('line_date >= ? AND line_date <= ?', fd, td).order('line_date') }


  scope :unlocked, where('locked = ?', false)
  scope :before_including_day, lambda {|d| where('lines.line_date <= ?',d)}
  scope :sum_debit_before, lambda {|d| where('line_date < ?', d).sum(:debit)}
  scope :sum_credit_before, lambda {|d| where('line_date < ?', d).sum(:credit)}
  
  # donne le support de la ligne (ou sa contrepartie) : la banque ou la caisse
  def support
    return bank_account.acronym if bank_account_id
    return cash.name if cash_id
  end

  


  # # monthly sold donne le solde d'un mois fourni au format mm-yyyy
  # FIXME va poser des problèmes avec plusieurs organismes
#  def self.monthly_sold(month)
#    lines = Line.month(month)
#    lines.sum(:credit) - lines.sum(:debit)
#  end
  
#  def pick_date
#    line_date ? (I18n::l line_date) : nil
#  end
#
#  def pick_date=(string)
#    s = string.split('/')
#    self.line_date = Date.civil(*s.reverse.map{|e| e.to_i})
#  rescue ArgumentError
#    self.errors[:line_date] << 'Date invalide'
#    nil
#  end
  
# surcharge de restore qui est définie dans models/restore/restore_records.rb
  def self.restore(new_attributes)
    Line.skip_callback(:save, :before, :check_bank_and_cash_ids)
    super
  ensure
    Line.set_callback(:save, :before, :check_bank_and_cash_ids)
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

  # méthode utilisée pour la remise des chèques (pour afficher les chèques dans la zone de sélection)
  def check_for_select
  "#{I18n.l line_date, :format=>'%d-%m'} - #{narration} - #{format('%.2f',credit)}"
  end

  def destination_name
    destination ? destination.name : 'non indiqué'
  end

  def nature_name
    self.nature ? self.nature.name : 'non indiqué'
  end

  protected

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
