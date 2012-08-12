class Room < ActiveRecord::Base
  establish_connection Rails.env

  belongs_to :user

  def organism
    look_for { Organism.first }
  end

  def complete_db_name
    [database_name, Rails.application.config.database_configuration[Rails.env]['adapter']].join('.')
  end

  def absolute_db_name
    File.join(Rails.root, PATH_TO_ORGANISMS, complete_db_name)
  end


  # look_for permet de chercher quelque chose dans la pièce
  # Le block indique ce qu'on cherche
  # 
  # Usage look_for {Organism.first} (qui est également définie dans cette classe comme méthode organism
  # ou look_for {Archive.last}
  #
  def look_for(&block)
    cc = ActiveRecord::Base.connection_config
    ActiveRecord::Base.use_org_connection(database_name)
    r = yield
    ActiveRecord::Base.establish_connection(cc)
    return r
  end


  # look_forg permet d'éviter d'écrire à chaque fois Organism.first
  # le bloc soit être alors un string
  # Usage : room.look_forg {"accountable?"} ou room.look_forg {"books.first"}
  def look_forg(&block)
    cc = ActiveRecord::Base.connection_config
    ActiveRecord::Base.use_org_connection(database_name)
    org = Organism.first
    r = org.send yield
    ActiveRecord::Base.establish_connection(cc)
    return r
  end


 

end
