# Sert de base pour les masques d'écriture en enregistrant juste un titre et 
# un commentaire.
# Les informations pertinentes sont stockées dans la table MaskField qui doit 
# comprendre à chaque fois un certain nombre de champs dont la liste est données
# par LIST_FIELDS.
# 
# Des méthodes correspondant à chacun de ses champs permettent de récupérer 
# l'enregistrement voulu.  
#
class Mask < ActiveRecord::Base
  belongs_to :organism
  
  attr_accessible :comment, :title, :book_id, :ref, :narration, 
    :destination_id, :nature_name, :mode, :amount, :counterpart
  
  validates :title, :organism_id, :book_id, presence:true
  validates :title, :format=>{with:NAME_REGEX}, :length=>{:within=>LONG_NAME_LENGTH_LIMITS}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  
  validate :nature_coherent_with_book, :if=>"nature_name"
  validate :counterpart_coherent_with_mode,  :if=>"mode && counterpart"
  
  
  LIST_FIELDS = %w(book_id ref narration nature_name destination_id amount mode counterpart )
  
     
  # renvoie le livre sollicité par ce masque
  def book
    Book.find_by_id(book_id) 
  end
#  
#  # renvoie la destination sollicitée par ce masque
  def destination
    Destination.find_by_id(destination_id)
  end
  
  def cash
    organism.cashes.find_by_name(counterpart) if counterpart
  end
  
  def bank_account
    organism.bank_accounts.find_by_name(counterpart) if counterpart
  end
  
  protected
  
  def nature_coherent_with_book
    type_of_nature = Nature.find_by_name(nature_name).collect(&:income_outcome).uniq.first
    if book.type == 'IncomeBook' && type_of_nature == false
      errors.add(:book_id, 'Incohérent avec le type de nature')
      errors.add(:nature_name, 'Incohérent avec le type de livre choisi')
    end
  end
  
  # FIXME un bug possible pourrait apparaître si il y a un nickname de comptebancaire
  # et un nom de caisse identiques. Peu probable, mais pourrait arriver.
  def counterpart_coherent_with_mode
    if mode == 'Espèces' && !cash
      errors.add(:mode, 'Incohérent avec la contrepartie')
      errors.add(:counterpart, 'Incohérent avec un paiement en espèces')
    end
    
    if DIRECT_BANK_PAYMENT_MODES.include?(mode) && !bank_account
      errors.add(:mode, 'Incohérent avec la contrepartie')
      errors.add(:counterpart, "Incohérent avec un paiement en #{mode}")
    end
    
    if mode == 'Chèque' && book.type == 'IncomeBook' && counterpart != 'Chèque à l\'encaissement' 
      errors.add(:mode, 'Incohérent avec la contrepartie')
      errors.add(:counterpart, "Incohérent avec un règlement par #{mode}")
    end
  end
  
  
  

end
