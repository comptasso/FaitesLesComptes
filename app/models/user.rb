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

  before_destroy :destroy_owned_organisms, prepend:true
  after_destroy :destroy_related_tenant

  # renvoie les rooms qui sont détenues par le user
  def owned_organisms
    holders.where('status = ?', 'owner').map(&:organism)
  end

  # Un User est autorisé à créer un organisme s'il a le rôle Expert
  # ou si le nombre de ses comptas est inférieurs à 4
  def allowed_to_create_organism?
    return true if role == 'expert'
    holders.where('status = ?', 'owner').count < 4
  end

  protected

  def destroy_owned_organisms
    owned_organisms.each do |o|
      o.destroy
      # TODO destruction des users qui n'ont d'autre rôle que guest sur cet
      # organisme -> à faire dans un before_destroy de Organism
    end
  end

  def destroy_related_tenant
    # TODO voir comment détruire un tenant si ce user était le dernier
    # en lien avec ce tenant.
  end


end
