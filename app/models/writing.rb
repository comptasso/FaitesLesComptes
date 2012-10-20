# coding: utf-8

# Writing représente des écritures dans la comptabilité
# Writing a des compta_lines :un modèle basé sur la même table que Line
# mais avec des validations différentes.
#
# 
#
class Writing < ActiveRecord::Base
  include Utilities::PickDateExtension # apporte les méthodes pick_date_for

  pick_date_for :date

  belongs_to :book
 
  has_many :compta_lines, :dependent=>:destroy
  alias children compta_lines
  
  

  validates :book_id, :narration, :date, presence:true
  validates :date, :must_belong_to_period=>true
  validates :compta_lines, :two_compta_lines_minimum=>true
  validate :balanced?
  validate :period_start_date, :if=> lambda {book.type == 'AnBook'}

  accepts_nested_attributes_for :compta_lines, :allow_destroy=>true

  default_scope order('date ASC')
  
  scope :period, lambda {|p| where('date >= ? AND date <= ?', p.start_date, p.close_date)}
  scope :mois, lambda { |date| where('date >= ? AND date <= ?', date.beginning_of_month, date.end_of_month) }

  # Fait le total des debit des compta_lines
  # la méthode utilisée permet de neutraliser les nil éventuels
  # utile notamment pour les tests de validité
  def total_debit
    compta_lines.inject(0) {|tot, cl| cl.debit ? tot + cl.debit  : tot}
  end

  # Fait le total des debit des compta_lines
  # la méthode utilisée permet de neutraliser les nil éventuels
  def total_credit
    compta_lines.inject(0) {|tot, cl| cl.credit ? tot + cl.credit  : tot}
  end

  # support renvoie le long_name du compte de la première ligne avec un compte de classe 5 de l'écriture
  def support
    s = supportline
    s.account.long_name if s && s.account
  end

  def supportline
    s = compta_lines.select {|cl| cl.account && cl.account.number =~ /^5.*/}
    s.first if s
  end

  # indique si une écritue est équilibrée ou non
  # ajoute une erreur si déséquilibrée
  def balanced?
    return false if compta_lines.size == 0 # Même s'il y a un validator two_compta_lines,
    # il ne s'exécute pas forcément avant celui ci d'où l'intérêt d'un test.
    if total_credit != total_debit
      logger.debug "Total débit : #{total_debit} - Total credit : #{total_credit}"
      errors.add(:base, 'Ecriture déséquilibrée')
      false
    else
      true
    end
  end

  # lock verrouille toutes les lignes de l'écriture
  def lock
    Writing.transaction do
      compta_lines.all.each do |cl|
        unless cl.locked?
          cl.update_attribute(:locked, true)
        end
      end
    end
  end

  def locked?
    compta_lines.all.select {|cl| cl.locked?}.any?
  end

  protected

  def period_start_date
    p = book.organism.find_period(date)
    if date != p.start_date
      errors.add(:date, 'Doit être le premier jour')
      false
    else
      true
    end
  end

 
  
end
