# -*- encoding : utf-8 -*-

# Room est un modèle qui se situe dans la base principale et qui sert à
# enregistrer les noms des bases de données puisque chaque organisme dispose de
# sa propre base de donnée.
#
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

  # vérifie que les bases de données sont bien toutes de la bonne version
  def self.version_update?
    Room.find_each do |r|
      if r.connect_to_organism
         arm = ActiveRecord::Migrator.new(:up, ActiveRecord::Migrator.migrations_paths)
         if arm.pending_migrations.any?
           puts "Base #{r.database_name} nécessite une migration"
           return false
         end
      end
    end
    true
  end

  # Migre la table prinicpale dont dépend Room puis migre chacune des
  # bases de données qui sont référencées par Room
  #
  # Met à jour la version
  def self.migrate_each
    # ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
    cc = ActiveRecord::Base.connection_config
    Room.all.each do |r|
      # on se connecte successivement à chacun d'eux
      if r.connect_to_organism
        puts "migrating #{r.absolute_db_name}"
        # et appel pour chacun de la fonction voulue
        ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
        Organism.first.update_attribute(:version, VERSION)
      end
    end
     ActiveRecord::Base.establish_connection(cc)
  end

  

  # renvoie par exemple asso.sqlite3
  def db_filename
    [database_name, Rails.application.config.database_configuration[Rails.env]['adapter']].join('.')
  end

  # pour sortir les bases de données du répertoire de l'application 
  def self.path_to_db 
    if Rails.env == 'test'
      File.join(Rails.root, 'db', Rails.env, 'organisms')
    elsif ENV['OCRA_EXECUTABLE']
      File.join(ENV['OCRA_EXECUTABLE'], '..', 'db', Rails.env, 'organisms')
    else
      File.join(Rails.root, '..', 'db', Rails.env, 'organisms')
    end
  end

  # renvoie par exemple 'app/db/test/organisms/asso.sqlite3'
  def absolute_db_name
    File.join(Room.path_to_db, db_filename)
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

  alias enter connect_to_organism

  # La méthode de classe enter est un raccouci pour find(id).enter
  def self.enter(id)
    r = Room.find_by_id(id)
    if r
      r.enter
    else
      raise ArgumentError, "Pas de Room avec #{id} pour id"
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
