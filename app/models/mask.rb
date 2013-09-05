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
  has_many :mask_fields, inverse_of: :mask, :dependent=>:destroy
  
  accepts_nested_attributes_for :mask_fields
  
  attr_accessible :comment, :title, :mask_fields_attributes
  
  validates :title, :organism_id, presence:true
  validates :title, :format=>{with:NAME_REGEX}, :length=>{:within=>LONG_NAME_LENGTH_LIMITS}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  
  LIST_FIELDS = %w(book_id ref narration nature_name destination_id amount mode counterpart )
  
  # Définit les méthodes book_id, ...
  LIST_FIELDS.each do |field|
    define_method(field.to_sym) do
      mask_fields.where('label = ?', field ).first
    end
  end
  
  # Définit les méthodes book_id_content, ...
  LIST_FIELDS.each do |field|
    define_method((field + '_content').to_sym) do
      field ? self.send(field).content : nil
    end
  end
    
  # renvoie le livre sollicité par ce masque
  def book
    Book.find_by_id(book_id_content)
  end
  
  # renvoie la destination sollicitée par ce masque
  def destination
    Destination.find_by_id(destination_id_content)
  end
  
  
  
  
  

end
