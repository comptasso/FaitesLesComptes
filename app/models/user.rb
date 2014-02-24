require 'strip_arguments'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  has_many :rooms, :dependent=>:destroy

  strip_before_validation :name

  validates :name, presence: true, uniqueness:true, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :role, presence: true, :inclusion=>{:in=>['standard', 'expert'] }
  
  
  def enter_first_room
    rooms.first
  end
  
  # retourne un array de hash des organismes et des chambres appartenat à cet user
  # le hash ne comprend que les organimes qui ont pu être effectivement trouvés
  def organisms_with_room
    owrs = rooms(true).collect { |r| {organism:r.organism, room:r} }
    owrs.select {|o| o[:organism] != nil}
  end

  # retourne un hash pour la zone Compta avec les seulement les organismes qui
  # sont accountable.
  #
  # s'appuie sur organism_with_rooms et ne retient que les accountable?
  def accountable_organisms_with_room
    rooms.select {|r|  r.look_for { r.organism.accountable? } }
  end

  # retourne un hash pour la zone de Saisie avec seulement les organismes qui
  # ont un exercice
  #
  # s'appuie sur organism_ith_rooms et ne retient que ceux qui ont un organisme
  def saisieable_organisms_with_room
    rooms.select {|r| r.look_for {r.organism.periods.any?} }
  end

  # up_to_date effectue un contrôle des bases de l'utilisateur
  # sur la totalité des rooms qui lui appartiennent.
  #
  # Pour chaque base, up_to_date? collecte les données de relative_version.
  #
  # Si toutes les bases renvoient :same_migration, alors up_to_date? renvoie
  # true, false sinon;
  #
  # Renvoie également true s'il n'y pas de base
  #
  def up_to_date?
    return true if status.empty?
    status == [:same_migration] ? true : false
  end

  # status collecte les différents statuts des bases de données appartenant
  # au user
  def status
    rooms.map {|r| r.relative_version}.uniq
  end

  def allowed_to_create_room?
    return true if role == 'expert'
    rooms(true).count < 4
  end

 

 

  
end
