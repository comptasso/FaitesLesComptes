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
 
  has_many :compta_lines, :as=>:owner, :dependent=>:destroy
  alias children compta_lines
  
  

  validates :book_id, :narration, :date, presence:true
  validates :date, :must_belong_to_period=>true
  validates :compta_lines, :two_compta_lines_minimum=>true
  validate :balanced?

  accepts_nested_attributes_for :compta_lines, :allow_destroy=>true

  default_scope order('date ASC')
  scope :mois, lambda { |date| where('date >= ? AND date <= ?', date.beginning_of_month, date.end_of_month) }

  def total_debit
    compta_lines.inject(0) {|tot, cl| tot += cl.debit if cl.debit}
  end

  def total_credit
    compta_lines.inject(0) {|tot, cl| tot += cl.credit if cl.credit}
  end

   # support renvoie le long_name de la première ligne avec un compte de classe 5 de l'écriture
  def support
    s = compta_lines.select {|cl| cl.account && cl.account.number =~ /^5.*/}
    s.first.long_name if s
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
        cl.locked = true
        cl.save
      end
      end
    end
  end

  def locked?
    compta_lines.all.select {|cl| cl.locked?}.any?
  end

 
  
end
