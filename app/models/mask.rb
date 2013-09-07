# Sert de base pour les masques d'écriture en enregistrant juste un titre et 
# un commentaire et le livre.
# Plus les informations facultatives telles que ref, narration, destination_id
# nature_name, mode, amount et counterpart. 
# 
# nature_name et counterpart sont des string qui permettront de retrouver la nature 
# et le compte bancaire ou la caisse dès lors que la date de l'écriture sera donnée.
# 
# Les méthodes book, destination, bank_account et cash permettent de retrouver
# les enregistrements correspondant à ce masque.
# 
# A noter que la date n'est pas fixée.
# 
# Différentes validations permettent de vérifier que les informations sont cohérentes
# Par exemple, le type de nature (income ou outcome) doit être cohérent avec le livre
# (Recettes ou Dépenses).  
# De même pour le mode de règlement avec la contrepartie.
# 
#
class Mask < ActiveRecord::Base
  belongs_to :organism
  
  attr_reader :writing
  
  attr_accessible :comment, :title, :book_id, :ref, :narration, 
    :destination_id, :nature_name, :mode, :amount, :counterpart
  
  validates :title, :organism_id, :book_id, presence:true
  validates :title, :format=>{with:NAME_REGEX}, :length=>{:within=>LONG_NAME_LENGTH_LIMITS}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  validates :book_id, numericality:true
  validates :destination_id, numericality:true, allow_blank:true
  validates :amount, numericality:{:greater_than=>0.0}, allow_blank:true
  validates :narration, :ref, :nature_name, :mode, :counterpart,
    :format=>{with:NAME_REGEX}, :length=>{:within=>LONG_NAME_LENGTH_LIMITS}, :allow_blank=>true
  
  validate :nature_coherent_with_book, :if=>"nature_name"
  validate :counterpart_coherent_with_mode,  :if=>"mode && counterpart"
  
  
  LIST_FIELDS = %w(book_id ref narration nature_name destination_id amount mode counterpart)
  
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
    organism.bank_accounts.find_by_nickname(counterpart) if counterpart
  end
  
  # construit les éléments du writing
  def writing_new(date)
    return  build_writing(date), line(date), counterline(date)
  end
  
  protected
  
  # construit un in_out_writing
  def build_writing(date)
    @writing = book.in_out_writings.new(date:date, ref:ref, narration:narration)
  end
  
  def line(date)
    writing.compta_lines.build(nature_id:nature_id(date), debit:debit, credit:credit, destination_id:destination.id)
  end
  
  def counterline(date)
    writing.compta_lines.build(payment_mode:mode, debit:credit, credit:debit, account_id:account_id(date))
  end
  
  def nature_id(date)
    organism.find_period(date).natures.find_by_name(nature_name).id if nature_name
  end
  
  def debit
    if amount
      book.type == 'IncomeBook' ? 0 : amount
    end
  end
  
  def credit
    if amount
      book.type == 'IncomeBook' ? amount : 0
    end
  end
  
  # renvoie le compte comptable correspondant à la contrepartie
  def account_id(date)
    return nil unless counterpart
    p = organism.find_period(date)
    return cash.current_account(p).id if cash
    return bank_account.current_account(p).id if bank_account
    return p.rem_check_account.id if counterpart == 'Chèque à l\'encaissement'
  end
  
  
  
  
  def nature_coherent_with_book
    type_of_nature = Nature.find_by_name(nature_name).income_outcome
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
