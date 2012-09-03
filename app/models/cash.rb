
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


  def to_s
    name
  end

  # utilisé dans l'affichage des transfer pour construire les id du select
  def to_option
    "#{self.class.name}_#{id}"
  end

  



end
