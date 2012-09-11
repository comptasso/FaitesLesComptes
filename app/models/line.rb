# -*- encoding : utf-8 -*-

# La classe Line est la classe qui enregistre les lignes d'écritures dans les 
# livres de recettes et de dépenses. 
# Ses attributs sont donc nombreux 
# 
#   t.date     "line_date" => date de l'écriture
#    t.string   "narration" => libellé
#    t.integer  "nature_id" => nature de rattachement
#    t.integer  "destination_id" => destination de rattachement
#    TODO remplacer debit credit par amount et un champ booléen pour
#    éviter des validations compliquées (et rajouter les attributs virtuels 
#    qui vont bien
#   
#    t.decimal  "debit",            :default => 0.0 => montant au débit
#    t.decimal  "credit",           :default => 0.0 => montant au crédit
#    t.integer  "book_id" => livre de rattachement 
#    t.boolean  "locked",           :default => false => verrouillage
#    une écriture locked ne peut être détruite (grâce à cant_change_if_locked
#    appelé par before destroy, 
#    Certains champs de l'écriture ne peuvent être édités si locked grâce 
#    au validator cant_edit_if_locked 
#    
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    
#    Les deux champs suivants sont prévus pour pouvoir gérer la création de lignes
#    à partir d'une ligne existante 
#    TODO mettre en place cette fonctionnalité ou supprimer ces 2 champs
#    t.string   "copied_id"  => actuellement non utilisé
#    t.boolean  "multiple",         :default => false => actuellement non utilisé
#    
#    t.integer  "bank_extract_id" => rattachement à un extrait de compte
#    t.string   "payment_mode" => mode de payement (voir les constantes dans config=
#    t.integer  "check_deposit_id" => rattachement à une remise de chèque
#    t.integer  "cash_id" => rattachement à une caisse
#    t.integer  "bank_account_id" => rattachement à un compte bancaire
#    
#    Owner est le propriétaire (polymorphique)
#    Actuellement uniquement utilisé pour les virements (cela permet de 
#    rattacher l'écriture à un virement.
#    A terme, ce  champ polymorphique pourrait peut-être servir pour d'autres motifs de création
#    de lignes (par exemple des abonnements ? )
#    t.integer  "owner_id" => rattache
#    t.string   "owner_type"
#    
#    t.string   "ref" => un champ de référence pur l'écriture
#    t.string   "check_number" => un champ pour enregistrer le numéro du chèque si c'est un chèque
#
class Line < ActiveRecord::Base

  include Utilities::PickDateExtension # apporte les méthodes pick_date_for

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
  has_and_belongs_to_many :bank_extract_lines, :uniq=>true # pour les rapprochements bancaires

  has_many   :lines, :as=>:owner, :dependent=>:destroy


  pick_date_for :line_date
  
  before_save  :fill_account, :if=> lambda {nature && nature.account}
  before_save :fill_rem_check_account, :if => lambda {self.book.class == IncomeBook && self.payment_mode == 'Chèque'}
  after_create :create_counterpart
  after_update :update_counterpart

  before_destroy :cant_change_if_locked

 
  # voir au besoin les validators qui sont dans lib/validators
  validates :debit, :credit, numericality: true, two_decimals:true  # format: {with: /^-?\d*(.\d{0,2})?$/}
  validates :book_id, presence:true
  validates :line_date, presence: true
  validates :line_date, must_belong_to_period: true
  validates :nature_id, presence: true, :unless => lambda { self.account_id || self.account }
  validates :narration, presence: true
  validates :payment_mode, presence: true,  :inclusion => { :in =>PAYMENT_MODES ,
    :message => "mode de paiement inconnu" }, :if=>lambda { self.book.class == IncomeBook || self.book.class == OutcomeBook }
  validates :debit, :credit, :not_null_amounts=>true, :not_both_amounts=>true
  validates :credit, presence: true # du fait du before validate, ces deux champs sont toujours remplis
  validates :debit, presence: true # mais ces validates ont pour objectif de mettre un * dans le formulaire
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
  scope :range_date, lambda { |fd,td| where('line_date >= ? AND line_date <= ?', fd, td) }
  scope :parentlines, where('owner_id IS NULL')

  scope :unlocked, where('locked IS ?', false)
  scope :before_including_day, lambda {|d| where('lines.line_date <= ?',d)}
  
  # ne peuvent être transformées en scope car ne retournent pas un arel
  def self.sum_debit_before(date)
    where('line_date < ?', date).sum(:debit)
  end

  def self.sum_credit_before(date)
    where('line_date < ?', date).sum(:credit)
  end
  
  # donne le support de la ligne (ou sa contrepartie) : la banque ou la caisse
  def support
    aa =  children.first.account.accountable
    return 'Pas de support' unless aa
    aa.to_s
  end

  def children
    lines
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

  
  
  def cant_change_if_locked
    !locked
  end

  # remplit le champ account_id avec celui associé à nature si nature est effectivement associée à nature
  # traite également le cas particulier d'une recette par chèque pour remplir le counter_account
  # avec le compte Chèques à l'encaissement
  def fill_account
    self.account_id = nature.account.id
  end

  # cas particulier d'une remise de chèque, la contrepartie n'est pas une caisse ou une banque 
  # mais le compte remise à l'encaissement
  def fill_rem_check_account
    p = book.organism.find_period(line_date)
    cas = p.accounts.where('number LIKE ?', '52%')
    if cas.empty?
      self.errors[:payment_mode] << 'Pas de compte chèque à encaisser' if cas.empty?
      return false
    else
      self.counter_account_id = cas.first.id
    end
  end

  # crée la ligne de contrepartie pour les écritures enregistrées dans les livres de recettes et de dépenses
  def create_counterpart
    # si le livre est un IncomeBook ou un OutcomeBook
    if book.class == IncomeBook || book.class == OutcomeBook
      l = ComptaLine.new(line_date:line_date, narration:narration,
        book_id:book.id,
        account_id:counter_account_id,
        debit:credit, credit:debit,
        payment_mode:payment_mode,
        owner_id:id, owner_type:'Line')
      logger.debug "Dans create counterpart, ligne : #{l.inspect}" unless l.valid?
      l.save
    end

  end

  # met à jour la ligne de contrepartie pour les écritures enregistrées par la saisie
  def update_counterpart

  end


  
end
