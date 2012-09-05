# coding: utf-8

# La class Cash correspond à une caisse
#
class Cash < ActiveRecord::Base
  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
#  include Utilities::Sold
  include Utilities::JcGraphic
  
  belongs_to :organism
  # ne plus utiliser, cash_id va disparaître
  has_many :counterlines, :through=>:accounts
  has_many :cash_controls
  # un caisse a un compte comptable par exercice
  has_many :accounts, :as=> :accountable


  # Un transfert est un virement fait d'une caisse ou d'un compte bancaire
  # vers une caisse ou un compte bancaire.
  # La caisse peut être débitée d'un montant ou créditée.
  # Transfer est donc polymorphique pour le débit et pour le crédit.
  # D'où les deux has_many.   .
#  has_many :d_transfers, :as=>:debitable, :class_name=>'Transfer'
#  has_many :c_transfers, :as=>:creditable, :class_name=>'Transfer'

  validates :name, :presence=>true, :uniqueness=>{:scope=>:organism_id}

  after_create :create_accounts

  # retourne le numéro de compte de la caisse correspondant à l'exercice (period) passé en argument
  def current_account(period)
    accounts.where('period_id = ?', period.id).first
  end

  def to_s
    name
  end

  def cumulated_debit_before(date)
    p = organism.find_period(date)
    counterlines.where('line_date < ?', date).sum(:debit)
  end

  def cumulated_credit_before(date)
    counterlines.where('line_date < ?', date).sum(:credit)
  end

  def sold_before(date = Date.today)
    p = organism.find_period(date)
    cumulated_credit_before(date) - cumulated_debit_before(date)
  end

  def cumulated_debit_at(date)
    p = organism.find_period(date)
    counterlines.where('line_date <= ?', date).sum(:debit)
  end

  def cumulated_credit_at(date)
    p = organism.find_period(date)
    counterlines.period(p).where('line_date <= ?', date).sum(:credit)
  end

  def sold_at(date)
    cumulated_credit_at(date) - cumulated_debit_at(date)
  end

  # donne un solde en prenant toutes les lignes du mois correspondant
  # à cette date; Le selector peut être une date ou une string
  # sous le format mm-yyyy
  # S'appuie sur le scope mois de Line
  def monthly_value(selector)
    if selector.is_a?(String)
      selector = Date.civil(selector[/\d{4}$/].to_i, selector[/^\d{2}/].to_i,1)
    end
    r = counterlines.select([:debit, :credit, :line_date]).mois(selector).sum('credit - debit') if selector.is_a? Date
    return r.to_f  # nécessaire car quand il n'y a pas de lignes, le retour est '0' et non 0
  end

 

  protected
 # appelé par le callback after_create, crée un compte comptable de rattachement
 # pour chaque exercice ouvert.
 def create_accounts
   logger.info 'création des comptes liés à la caisse'
   # demande un compte de libre sur l'ensemble des exercices commençant par 51
   n = Account.available('53') # un compte 53 avec un précision de deux chiffres par défaut
   organism.periods.where('open = ?', true).each do |p|
     self.accounts.create!(number:n, period_id:p.id, title:self.name)
   end
 end
  



end
