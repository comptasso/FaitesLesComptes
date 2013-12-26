# Sert de base pour les masques d'écriture en enregistrant juste un titre et 
# un commentaire et le livre.
# Plus les informations facultatives telles que ref, narration, destination_id
# nature_name, mode, amount et counterpart. 
# 
# Les champs sont les suivants
#    t.string   "title"
#    t.text     "comment"
#    t.integer  "organism_id"
#    t.datetime "created_at",     :null => false
#    t.datetime "updated_at",     :null => false
#    t.integer  "book_id"
#    t.string   "nature_name"
#    t.string   "narration"
#    t.integer  "destination_id"
#    t.string   "mode"
#    t.string   "counterpart"
#    t.string   "ref"
#    t.decimal  "amount"
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
# Un masque peut servir pour une saisie directement, mais aussi pour un abonnement
# avec la relation has_one subscription
# 
#
class Mask < ActiveRecord::Base
  belongs_to :organism
  has_one :subscription
  
  has_many :writings, as: :bridge
  
  attr_reader :writing
  
  attr_accessible :comment, :title, :book_id, :ref, :narration, 
    :destination_id, :nature_name, :mode, :amount, :counterpart
  
  validates :title, :organism_id, :book_id, presence:true
  validates :title, :format=>{with:NAME_REGEX}, :length=>{:within=>LONG_NAME_LENGTH_LIMITS}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  validates :book_id, numericality:true
  validates :destination_id, numericality:true, allow_blank:true
  validates :amount, numericality:{:greater_or_equal_to=>0.0}, allow_blank:true
  validates :ref, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}, :allow_blank=>true
  validates :narration, :nature_name, :counterpart,
    :format=>{with:NAME_REGEX}, :length=>{:within=>LONG_NAME_LENGTH_LIMITS}, :allow_blank=>true
  validates :mode, inclusion: {in: PAYMENT_MODES}, :allow_blank=>true
  
  validate :nature_coherent_with_book, :if=>"nature_name.present?"
  validate :counterpart_coherent_with_mode,  :if=>"mode.present? && counterpart.present?"
  
  
  LIST_FIELDS = %w(book_id ref narration nature_name destination_id amount mode counterpart)
  
  # renvoie le livre sollicité par ce masque
  def book
    organism.books.find_by_id(book_id) 
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
  
  # construit les éléments du writing, renvoie une écriture et ses deux compta_lines
  # 
  # Utilisé par writing_masks_controller pour générer les champs de saisie
  def writing_new(date)
    return  build_writing(date), line(date), counterline(date)
  end
  
  # construit seulement les paramètres de l'écriture.
  # Utilisé par Utilities::Writer en lien avec Subscription pour créer
  # l'écriture automatiquement. 
  def complete_writing_params(date)
    w, cl1, cl2 = writing_params(date), line_params(date), counter_line_params(date)
    w.merge(:compta_lines_attributes=>{'0'=>cl1, '1'=>cl2})
  end
  
    
  protected
  
  # construit un in_out_writing
  def build_writing(date)
    @writing = book.in_out_writings.new(writing_params(date))
  end
  
  def line(date)
    writing.compta_lines.build(line_params(date))
  end
  
  def counterline(date)
    writing.compta_lines.build(counter_line_params(date))
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
    type_of_nature = organism.natures.find_by_name(nature_name).income_outcome
    if (book.type == 'IncomeBook' && type_of_nature == false) || (book.type == 'OutcomeBook' && type_of_nature == true)
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
  
  private
  
  def writing_params(date)
    {date:date, ref:ref, narration:narration, bridge_type:'Mask', bridge_id:id}
  end
  
  def line_params(date)
    {nature_id:nature_id(date), debit:debit, credit:credit, destination_id:destination_id}
  end
  
  def counter_line_params(date)
    {payment_mode:mode, debit:credit, credit:debit, account_id:account_id(date)}
  end
  

end
