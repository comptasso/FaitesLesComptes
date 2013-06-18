require 'strip_arguments'

class User < ActiveRecord::Base

  attr_accessible :name
  
  has_many :rooms, :dependent=>:destroy

  strip_before_validation :name

  validates :name, presence: true, uniqueness:true, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}

  def enter_first_room
    rooms.first
  end

  # retourne un array de hash des organismes et des chambres appartenat à cet user
  # le hash ne comprend que les organimes qui ont pu être effectivement trouvés
  def organisms_with_room
    owrs = rooms.collect { |r| {organism:r.organism, room:r} }
    owrs.select {|o| o[:organism] != nil}
  end

  # retourne un hash pour la zone Compta avec les seulement les organismes qui
  # sont accountable.
  #
  # s'appuie sur organism_with_rooms et ne retien que les accountable?
  def accountable_organisms_with_room
    organisms_with_room.select {|owr|  owr[:room].look_for {Organism.first.accountable?} }
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

 

  
end
