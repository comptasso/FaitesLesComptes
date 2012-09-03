# coding: utf-8

# La class Cash correspond à une caisse
#
class Cash < ActiveRecord::Base
  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold
  include Utilities::JcGraphic

 
  
  belongs_to :organism
  has_many :lines
  has_many :cash_controls
  # un caisse a un compte comptable par exercice
  has_many :accounts, :as=> :accountable

  # Un transfert est un virement fait d'une caisse ou d'un compte bancaire
  # vers une caisse ou un compte bancaire.
  # La caisse peut être débitée d'un montant ou créditée.
  # Transfer est donc polymorphique pour le débit et pour le crédit.
  # D'où les deux has_many.   .
  has_many :d_transfers, :as=>:debitable, :class_name=>'Transfer'
  has_many :c_transfers, :as=>:creditable, :class_name=>'Transfer'

  validates :name, :presence=>true, :uniqueness=>{:scope=>:organism_id}

  after_create :create_accounts

  def to_s
    name
  end

  # utilisé dans l'affichage des transfer pour construire les id du select
  def to_option
    "#{self.class.name}_#{id}"
  end

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
