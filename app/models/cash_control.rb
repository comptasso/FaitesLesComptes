#
# CashControl représente une opération de contrôle de la caisse qui consiste
# à compter la caisse et à enregistrer son montant à la date donnée.
# Plusieurs cas sont alors possibles :
# Les écritures de caisse sont à jour et il n'y a pas d'écart
# Les écritures sont à jour et il y a un écart
# Les écritures de caisse ne sont pas à jour.
#
# La validation des écritures de caisse doit donc être faites à un moment indépendant
# et ne peut être faite par un after_create,
#
class CashControl < ActiveRecord::Base
  belongs_to :cash

  validates :date, :cash_id, :amount, presence: true
  validates :amount, numericality: true

  scope :for_period, lambda {|p| where('date >= ? and date <= ?', p.start_date, p.close_date).order('date ASC')}

 
end
