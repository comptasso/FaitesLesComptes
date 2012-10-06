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
  
  before_validation :complete_lines

  validates :book_id, :narration, :date, presence:true
  validates :date, :must_belong_to_period=>true
  validates :compta_lines, :two_compta_lines_minimum=>true
  validate :balanced?

  accepts_nested_attributes_for :compta_lines, :allow_destroy=>true

  default_scope order('date ASC')

  def total_debit
    compta_lines.sum(:debit)
  end

  def total_credit
    compta_lines.sum(:credit)
  end

  # indique si une écritue est équilibrée ou non
  # ajoute une erreur si déséquilibrée
  def balanced?
    return false if compta_lines.size == 0 # Même s'il y a un validator two_compta_lines,
    # il ne s'exécute pas forcément avant celui ci d'où l'intérêt d'un test.
    b =  (total_credit == total_debit)
    errors.add(:base, 'Ecriture déséquilibrée') unless b
    b
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

  # recopie dans les lignes les informations de date, de narration et de livre
  # TODO ceci deviendra inutile lorsque toutes les écritures seront dépendantes de writing
  def complete_lines
   # puts "nombre de lignes de comptes #{compta_lines.size}"
    compta_lines.each do |cl|
     # puts cl.inspect
      cl.line_date = date
      cl.narration = narration
      cl.book_id = book.id
      logger.debug cl.inspect
    end
    true
  end
  
end
