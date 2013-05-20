# coding: utf-8
require 'strip_arguments'
# La class Cash correspond à une caisse
#
class Cash < ActiveRecord::Base
  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  #
 
  include Utilities::Sold
  include Utilities::JcGraphic

  attr_accessible :name, :comment

  belongs_to :organism
  # ne plus utiliser, cash_id va disparaître
  has_many :compta_lines, :through=>:accounts, :include=>:writing
  has_many :cash_controls
  # un caisse a un compte comptable par exercice
  has_many :accounts, :as=> :accountable

  strip_before_validation :name, :comment
  
  validates :name, presence: true, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}, :uniqueness=>{:scope=>:organism_id}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  validates :organism_id, :presence=>true
 
  
  after_create :create_accounts
  after_update :change_account_title, :if=> lambda {name_changed? }
  

  # retourne le numéro de compte de la caisse correspondant à l'exercice (period) passé en argument
  def current_account(period)
    accounts.where('period_id = ?', period.id).first rescue nil
  end

  

  def to_s
    name
  end

  alias nickname to_s
  alias title to_s
  
  # méthode surchargeant celle de Utilities::Sold, laquelle sert de base au calcul des soldes
  def cumulated_at(date, dc) 
    p = organism.find_period(date)
    return 0 unless acc = current_account(p)
    Writing.sum(dc, :select=>'debit, credit', :conditions=>['date <= ? AND account_id = ?', date, acc.id], :joins=>:compta_lines).to_f
    # to_f est nécessaire car quand il n'y a aucune compa_lines, le retour est '0' et non 0 ce qui pose des
    # problèmes de calcul
  end

     
 

  protected
 # appelé par le callback after_create, crée un cash_book puis un compte comptable de rattachement
 # pour chaque exercice ouvert.
 def create_accounts
   logger.info 'création des comptes liés à la caisse'
   # demande un compte de libre sur l'ensemble des exercices commençant par 51
   n = Account.available('53') # un compte 53 avec un précision de deux chiffres par défaut
   organism.periods.where('open = ?', true).each do |p|
     self.accounts.create!(number:n, period_id:p.id, title:self.name)
   end
 end

 # Permet d'avoir un libellé du compte plus clair en préfixant le libellé du compte
 # par le mot Caisse 
 def change_account_title
   accounts.each {|acc| acc.update_attribute(:title, 'Caisse '+ name)}
 end
 
  



end
