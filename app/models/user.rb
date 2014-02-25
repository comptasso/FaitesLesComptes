require 'strip_arguments'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  has_many :holders, :dependent=>:destroy
  has_many :rooms, :through=>:holders
  

  strip_before_validation :name

  validates :name, presence: true, uniqueness:true, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :role, presence: true, :inclusion=>{:in=>['standard', 'expert'] }
  
  # renvoie les rooms qui sont détenues par le user
  def owned_rooms
    holders.where('status = ?', 'owner').map(&:room) 
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
    owned_rooms.count < 4
  end

  protected
  
  # Méthode utilisée pour les tests
  # 
  # construit une nouvelle room. Ce nom alambiqué pour ne pas risquer de 
  # surcharger une méthode automatique des associations de Rails.
  #
  # On vérifie que les paramètres sont valides, avant de créer un holder
  # avec le statut propriétaire, puis on crée la Room. 
  # 
  # On sauve d'abord le holder (ce qui sauve également la room associée) avant de 
  # passer dans le schéma récemment créé et d'y sauver l'organisme
  # 
  # La méthode retourne l'organisme.  
  #
  def build_a_new_room(db_name, org_title, org_status)
    org = Organism.new(:database_name=>db_name, title:org_title, status:org_status)
    return org unless allowed_to_create_room? && org.valid?
    h = holders.new(status:'owner')
    r  = h.build_room(database_name:db_name)
    return org unless r.valid?
    User.transaction do
      h.save
      Apartment::Database.switch(db_name)
      org.save # ici on sauve org dans la nouvelle base
    end
    org
  end
 

  
end
