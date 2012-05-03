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
  validates_numericality_of :amount, :greater_than_or_equal_to=>0.0

  scope :for_period, lambda {|p| where('date >= ? and date <= ?', p.start_date, p.close_date).order('date ASC')}

  # sélectionne tous les contrôles de caisse relevant d'un mois donné pour une période donnée
  scope :mois, lambda {|p,mois| where('date >= ? AND date <= ?', 
      p.start_date.months_since(mois.to_i).beginning_of_month, p.start_date.months_since(mois.to_i).end_of_month).order('date ASC')}

  before_update :lock_lines, :if => lambda { self.changed_attributes.include?("locked") && self.locked == true }

  def pick_date
    date ? (I18n::l date) : nil
  end

  def pick_date=(string)
    s = string.split('/')
    self.date = Date.civil(*s.reverse.map{|e| e.to_i})
  rescue ArgumentError
    self.errors[:date] << 'Date invalide'
    nil
  end

 # private

  # verrouille les lignes correspondantes à un contrôle de caisse
  def lock_lines
    Rails.logger.info "Verrouillage des lignes de caisse suite au verrouillage du controle de caisse #{id}"
   
    period = self.cash.organism.find_period(self.date) # on trouve l'exercice correspondant à ce contrôle de caisse
    # Trouver les lignes de cette caisse de l'exercice, antérieures à la date du contrôle et non verrouillées
    if self.locked == true # si les lignes 
      self.cash.lines.period(period).where('lines.line_date <= ?',self.date).where('locked = ?', false).each    do |l|
        l.update_attribute(:locked, true)
      end
    end
  end
end

