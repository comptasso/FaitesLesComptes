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

  attr_accessible :name, :comment, :sector_id

  belongs_to :organism
  belongs_to :sector
  
  # ces deux has_many sont très proche mais le premier en incluant writing
  # a des effets indésirables sur les requêtes utilisées pour faire un pdf de la 
  # caisse (on n'arive plus à forcer les noms des colonnes qui sont utilisés pour le pdf).
  # Le second est utilisé pour extract_lines
  has_many :compta_lines, :through=>:accounts, :include=>:writing
  has_many :in_out_lines, :source=>:compta_lines, :through=>:accounts
  
  has_many :cash_controls
  # un caisse a un compte comptable par exercice
  has_many :accounts, :as=> :accountable
  
  has_one :export_pdf, as: :exportable

  strip_before_validation :name, :comment
  
  validates :name, presence: true, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}, :uniqueness=>{:scope=>:organism_id}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  validates :organism_id, :presence=>true
  # validates :sector_id, :presence=>true
 
  
  after_create :create_accounts, :if=>lambda {organism.periods.opened.any? }
  after_update :change_account_title, :if=> lambda {name_changed? }
  

  # retourne le numéro de compte de la caisse correspondant à l'exercice (period) passé en argument
  def current_account(period)
    accounts.where('period_id = ?', period.id).first rescue nil
  end
  
  # extrait les lignes entre deux dates. Cette méthode ne sélectionne pas sur un exercice.
  def extract_lines(from_date, to_date)
    in_out_lines.joins(:writing).where('writings.date >= ? AND writings.date <= ?', from_date, to_date).order('writings.date')
  end

  

  def to_s
    name
  end

  alias nickname to_s
  alias title to_s
  
  # méthode surchargeant celle de Utilities::Sold, laquelle sert de base au calcul des soldes
  # 
  # En fait délègue cumulated_at au compte sous jacent
  #
  def cumulated_at(date, dc) 
    p = organism.find_period(date)
    return 0 unless p && acc = current_account(p) # on teste p car l'exercice précédent peut être incomplet
    acc.cumulated_at(date, dc)
  end
  
  # On veut que le solde prenne en compte le solde de l'exercice précédent tant
  # que l'écriture d'à nouveau n'a pas été générée.
  # 
  # On cherche donc l'exercice précédent et on rajoute son solde si cet exercice
  # est ouvert (ce qui veut dire que l'écriture d'A Nouveau n'est pas encore passée).
  # 
  # Lorsque l'exercice a été clos, les écritures d'AN ont été passées et le solde 
  # donne donc la bonne valeur.
  #
  def sold_at(date)
    reponse = super
    p = organism.find_period(date)
    if p && p.previous_period? 
      pp = p.previous_period
      reponse += sold_at(pp.close_date) if pp.open
    end 
    reponse
  end
  
  
  def self.compte_racine
   RACINE_CASH
  end

     
 

  protected
  
 # appelé par le callback after_create, demande à l'organisme de lui créer les 
 # comptes comptables associés (ce qui ne sera fait que pour chacun des exercices
 # ouverts).
 def create_accounts
   logger.debug 'création des comptes liés à la caisse' 
   Utilities::PlanComptable.create_financial_accounts(self)
 end

 # Permet d'avoir un libellé du compte plus clair en préfixant le libellé du compte
 # par le mot Caisse 
 def change_account_title
   accounts.each {|acc| acc.update_attribute(:title, 'Caisse '+ name)}
 end
 
  



end
