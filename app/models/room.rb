# -*- encoding : utf-8 -*-

class Room < ActiveRecord::Base
  # Room est dans la base principale
  establish_connection Rails.env

  belongs_to :user

  validates :user_id, presence:true
  validates :database_name, presence:true, :format=>{:with=>/^[a-z][a-z0-9]*$/}, uniqueness:true
  
  # renvoie l'organisme associé à la base
  def organism
     look_for { Organism.first }
  end

  # renvoie un hash utilisé pour l'affichage de la table des organismes
  def organism_description
    if o = organism
      {organism:o, room:self, archive:(look_for {Archive.last}) }
    end
  end

  # renvoie par exemple asso.sqlite3
  def db_filename
    [database_name, Rails.application.config.database_configuration[Rails.env]['adapter']].join('.')
  end

  # renvoie par exemple 'app/db/test/organisms/asso.sqlite3'
  def absolute_db_name
    File.join(Rails.root, 'db', Rails.env, PATH_TO_ORGANISMS, db_filename)
  end

  # se connecte à l'organisme correspondant à la base de données
  # retourne true ou false
  # TODO à adapter si on change de base de données
  def connect_to_organism
    f_name  = absolute_db_name
    if File.exist? f_name
      logger.info "Connection à la base #{database_name}"
      # Renvoie un ActiveRecord::ConectionAdapter::ConnectionPool
      arca = ActiveRecord::Base.establish_connection(
        :adapter => "sqlite3",
        :database  => f_name)
      return arca ? true : false
    else
      logger.warn "Tentative de connection à la base #{database_name}, fichier non trouvé"
      false
    end
  end

  # contrôle d'intégrité de la base
  # TODO sera à adapter pour d'autres adapters si nécessaire
  #
  # sqlite renvoie un array avec un hash [{'integrity_check'=>'ok', 0=>'ok'}]
  # on teste le premier ok
  #
  def check_db
    i = look_for {ActiveRecord::Base.connection.execute('pragma integrity_check')}
    if i.is_a? Array
      logger.debug i.first['integrity_check']
      i.first['integrity_check'] == 'ok' ? true : false
    else
      logger.warn 'check_db  n a pas obtenu de réponse de sa requête'
      false
    end
  end

  # look_for permet de chercher quelque chose dans la pièce
  # Le block indique ce qu'on cherche
  #
  # Usage look_for {Organism.first} (qui est également définie dans cette classe comme méthode organism
  # ou look_for {Archive.last}
  #
  def look_for(&block)
    cc = ActiveRecord::Base.connection_config
    yield if connect_to_organism
  ensure
    ActiveRecord::Base.establish_connection(cc)
  end


  # look_forg permet d'éviter d'écrire à chaque fois Organism.first
  # le bloc doit être alors un string
  # Usage : room.look_forg {"accountable?"} ou room.look_forg {"books.first"}
  def look_forg(&block)
    cc = ActiveRecord::Base.connection_config
    if connect_to_organism
      org = Organism.first
      r = org.send yield
    end
  ensure
    ActiveRecord::Base.establish_connection(cc)
  end


 

end
