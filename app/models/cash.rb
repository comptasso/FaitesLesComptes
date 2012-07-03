
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

  # Un transfert est un virement fait d'une caisse ou d'un compte bancaire
  # vers une caisse ou un compte bancaire.
  # La caisse peut être débitée d'un montant ou créditée.
  # Transfer est donc polymorphique pour le débit et pour le crédit.
  # D'où les deux has_many.   .
  has_many :d_transfers, :as=>:debitable, :class_name=>'Transfer'
  has_many :c_transfers, :as=>:creditable, :class_name=>'Transfer'

  validates :name, :presence=>true, :uniqueness=>{:scope=>:organism_id}

  # calcule le solde d'une caisse à une date donnée en partant du début de l'exercice
  # qui inclut cette date
  # TODO en fait j'ai modifié ce comportement pour ne pas avoir ce problème de report
  # A réfléchir
#  def sold(date=Date.today)
#    ls= self.lines.where('line_date <= ?', date)
#    date <= Date.today ? ls.sum(:credit)-ls.sum(:debit) : 0
#  end




  # méthode utilisée par le module JcGraphic pour la construction des graphiques
  def monthly_value(date)
    cumulated_credit_at(date) - cumulated_debit_at(date)
#     ls= self.lines.where('line_date <= ?', date)
#     date <= Date.today ? ls.sum(:credit)-ls.sum(:debit) : 'null'
  end


  def to_s
    name
  end

  # utilisé dans l'affichage des transfer pour construire les id du select
  def to_option
    "#{self.class.name}_#{id}"
  end

  



end
