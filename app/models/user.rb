class User < ActiveRecord::Base

  establish_connection Rails.env

  attr_accessible :name
  
  has_many :rooms, :dependent=>:destroy

  validates :name, presence:true

  def enter_first_room
    rooms.first
  end

  # retourne un hash des organismes et des chambres appartenat à cet user
  # le hash ne comprend que les organimes qui ont pu être effectivement trouvés
  def organisms_with_room
    owrs = rooms.collect { |r| {organism:r.organism, room:r} }
    owrs.select {|o| o[:organism] != nil}
  end

  def accountable_organisms_with_room
   rs =  rooms.select {|groom| groom.look_forg { "accountable?"} }
   rs.collect { |groom| {organism:groom.organism, room:groom} }
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
