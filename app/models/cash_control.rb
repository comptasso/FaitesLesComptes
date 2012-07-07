# -*- encoding : utf-8 -*-

#
# CashControl représente une opération de contrôle de la caisse qui consiste
# à compter la caisse et à enregistrer son montant à la date donnée.
# Plusieurs cas sont alors possibles :
# Les écritures de caisse sont à jour et il n'y a pas d'écart
# Les écritures sont à jour et il y a un écart
# Les écritures de caisse ne sont pas à jour.
#
# La validation des écritures de caisse doit donc être faites à un moment indépendant
# et ne peut être faite par un after_create
#
class CashControl < ActiveRecord::Base
   include Utilities::PickDateExtension
   
  belongs_to :cash

  validates :date, :cash_id, :amount, presence: true
  validates :amount, two_decimals:true
  validates_numericality_of :amount, :greater_than_or_equal_to=>0.0
  validate :date_within_limit
  
  pick_date_for :date
  
  scope :for_period, lambda {|p| where('date >= ? and date <= ?', p.start_date, p.close_date).order('date ASC')}

  # sélectionne tous les contrôles de caisse relevant d'un mois donné pour une période donnée
  scope :mois, lambda {|p,mois| where('date >= ? AND date <= ?', 
      p.start_date.months_since(mois.to_i).beginning_of_month, p.start_date.months_since(mois.to_i).end_of_month).order('date ASC')}

  scope :monthyear, lambda {|my| where('date >= ? AND date <= ?',
     my.beginning_of_month, my.end_of_month  )}


  before_update :lock_lines, :if => lambda { self.changed_attributes.include?("locked") && self.locked == true }

  def cash_sold
    @cash_sold ||= cash.sold_at(date)
  end


  def difference
    amount - cash_sold
  end

  def different?
    difference.abs > 0.001
  end

  # renvoie la date minimum que peut prendre un new cash_control
  # soit à partir d'un exercice, ou s'il n'est pas précisé, à partir
  # de la date du cash_control, et enfin au besoin prend le début de
  # l'année en cours
  def min_date(exercice = nil)
    return exercice.start_date if exercice
    return period.start_date if period
    return Date.today.beginning_of_year
  end

  def max_date
    [period.close_date, Date.today].min rescue Date.today
  end


  # previous renvoie le controle de caisse précédent l'instance actuelle
  # cette sélection se fait sur la base de la date.
  # Il se pourrait qu'un problème existe en cas de plusieurs controles de caisse
  # le même jour, ce qui est peu probable vu la taille des organismes ciblés
  def previous
    if persisted?
   previous_cash = cash.cash_controls.for_period(period).order('date ASC').where('date <= ?', date).limit(2).all rescue nil
   return nil unless (previous_cash && previous_cash.size == 2)
   return previous_cash.first
    else
    return cash.cash_controls.for_period(period).order('date ASC').where('date <= ?', date).last rescue nil
    end
 end



  private

   def date_within_limit 
    if period
    errors[:date] <<  'Pas dans l\'exercice' if self.date < min_date
    errors[:date] << 'Pas dans l\'exercice' if self.date > max_date
    else
      errors[:date] << 'Pas d\'exercice'
    end
  end


  # verrouille les lignes correspondantes à un contrôle de caisse
  def lock_lines
    Rails.logger.info "Verrouillage des lignes de caisse suite au verrouillage du controle de caisse #{id}"
   
    # Trouver les lignes de cette caisse de l'exercice, antérieures à la date du contrôle et non verrouillées
    if self.locked == true 
       self.cash.lines.period(period).before_including_day(self.date).unlocked.each    do |l| 
        l.update_attribute(:locked, true)
      end
    end
  end

    # trouve l'exercice auquel appartient ce cash_control
  def period
    cash.organism.find_period(date) rescue nil
  end


end

