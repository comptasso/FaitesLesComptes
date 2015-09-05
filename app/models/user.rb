class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable, :async

# ajout lié au gem Milia
  acts_as_universal_and_determines_account

  has_many :holders, :dependent=>:destroy
  has_many :organisms, :through=>:holders
  has_many :rooms, :through=>:holders

  strip_before_validation :name

  validates :name, presence: true, uniqueness:true, :format=>{with:NAME_REGEX},
    :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :role, presence: true, :inclusion=>{:in=>['standard', 'expert'] }

  # renvoie les rooms qui sont détenues par le user
  def owned_organisms
    holders.where('status = ?', 'owner').map(&:organism)
  end

  # retourne un array de hash des organismes et des chambres appartenat à cet user
  # le hash ne comprend que les organimes qui ont pu être effectivement trouvés
#   def organisms_with_room
#     owrs = rooms(true).collect { |r| {organism:r.organism, room:r} }
#     owrs.select {|o| o[:organism] != nil}
#   end

  # retourne un hash pour la zone Compta avec les seulement les organismes qui
  # sont accountable.
  #
  # s'appuie sur organism_with_rooms et ne retient que les accountable?
  #
  # N'est plus utilisé maintenant que la liste des organismes n'est disponible
  # que dans le menu Admin
  #
#  def accountable_organisms_with_room
#    rooms.select {|r|  r.look_for { r.organism.accountable? } }
#  end

  # retourne un hash pour la zone de Saisie avec seulement les organismes qui
  # ont un exercice
  #
  # s'appuie sur organism_with_rooms et ne retient que ceux qui ont un organisme
#   def saisieable_organisms_with_room
#     rooms.select {|r| r.look_for {r.organism.periods.any?} }
#   end

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
#   def up_to_date?
#     return true if status.empty?
#     status == [:same_migration] ? true : false
#   end

  # status collecte les différents statuts des bases de données appartenant
  # au user
#   def status
#     rooms.map {|r| r.relative_version}.uniq
#   end


  def allowed_to_create_organism?
    return true if role == 'expert'
    holders.where('status = ?', 'owner').count < 4
  end

  protected




end
