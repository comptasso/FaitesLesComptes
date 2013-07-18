# -*- encoding : utf-8 -*-
require 'strip_arguments'
# Room est un modèle qui se situe dans la base principale et qui sert à
# enregistrer les noms des bases de données puisque chaque organisme dispose de
# sa propre base de donnée.
#
# Voir les commentaires sur versions_controller pour la gestion des migrations et
# des versions
#
class Room < ActiveRecord::Base
  
  belongs_to :user

  attr_accessible :database_name

  strip_before_validation :database_name
  
  validates :user_id, presence:true
  validates :database_name, presence:true, :format=>{:with=>/\A[a-z][a-z0-9]*\z/}, uniqueness:true 
  validates :database_name, :upper_limit=>true
  

  after_create :create_db, :connect_to_organism
  after_destroy :destroy_db if ActiveRecord::Base.connection_config[:adapter] == 'postgresql'
  
  # renvoie l'organisme associé à la base
  # TODO utiliser les méthode de apartment en l'occurence process
  def organism
    look_for { Organism.first }
  end

  def last_archive
    look_for {Archive.last}
  end

  # Vérifie que la base de données enregistrant les Room est bien dans la bonne version
  #
  # Il y a le cas où la base principale (celle qui enregistre User et Room) n'est
  # elle même pas à jour. Par exemple, si on démarre le serveur avec une nouvelle
  # version.
  #
  def self.version_update?
      arm = ActiveRecord::Migrator.new(:up, ActiveRecord::Migrator.migrations_paths)
      arm.pending_migrations.any? ? false : true
  end

  # relative_version compare la version de l'organisme
  # et indique si cet organisme est en avance ou en retard par rapport
  # aux migrations qui sont enregistrées dans Room
  #
  # La valeur retournée est un hash avec l'id de la Room et un symbole indiquant
  # l'état de la migration par rapport à la base principale (Room).
  #
  # nil si la base n'est pas trouvée.
  def relative_version
    room_last_migration  = Room.jcl_last_migration
    organism_last_migration = look_for {Organism.migration_version}
    if organism_last_migration
      v =:same_migration if room_last_migration == organism_last_migration
      v = :late_migration if room_last_migration > organism_last_migration
      v = :advance_migration if room_last_migration < organism_last_migration
    else
      v = :no_base
    end
    v
  end

  def late?
    relative_version == :late_migration ? true : false
  end

  def no_base?
    relative_version == :no_base ? true : false
  end

  def advanced?
    relative_version == :advance_migration ? true : false
  end

  def up_to_date?
    relative_version == :same_migration ? true : false
  end

  # renvoie la dernière migration de la base principale (Room et User)
  def self.jcl_last_migration
    ActiveRecord::Migrator.new(:up, ActiveRecord::Migrator.migrations_paths).migrated.last
  end

  # renvoie le lieu de stockage des bases de données
  def self.path_to_db
      File.join(Rails.root, 'db', Rails.env)
  end

  # construit le nom du fichier de la base en ajoutant l'adapter comme extension
  #
  # renvoie par exemple asso.sqlite3
  def db_filename
    if ActiveRecord::Base.connection_config[:adapter] == 'sqlite3'
      "#{database_name}.sqlite3"
    else
      database_name
    end
  end

  
  # renvoie par exemple 'app/db/test/asso.sqlite3' pour sqlite3
  # ou app/db/test/asso pour postgresql (ce qui n'est pas vraiment juste puisque
  # postgre utilise des schémas.
  # TODO voir s'il faut améliorer ce point (ou se passer de full_name)
  def full_name
    File.join(Room.path_to_db, db_filename)
  end


  # Migre la table prinicpale dont dépend Room puis migre chacune des
  # bases de données qui sont référencées par Room
  #
  # Met à jour la version
  def self.migrate_each
    Apartment::Database.process(Apartment::Database.default_db) do
        Rails.logger.info "migration de la base principale"
        ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
      end
    Apartment.database_names.each do |db|
      Rails.logger.info "Migration de la base #{db}"
      Apartment::Migrator.migrate db
    end
  ensure
    Apartment::Database.switch()
  end

  # se connecte à l'organisme correspondant à la base de données
  #
  # retourne true ou false
  def connect_to_organism
    Apartment::Database.switch(database_name)
  end

  alias enter connect_to_organism

  # La méthode de classe enter est un raccouci pour find(id).enter
  def self.enter(id)
    r = Room.find_by_id(id)
    if r
      r.enter
    else
      return nil
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
     Apartment::Database.process(database_name) {block.call}
  end





  protected

  def create_db
    if Apartment::Database.db_exist?(database_name)
      Rails.logger.info "Après création de Room :la base #{database_name} existe déjà"
      Apartment::Database.switch(database_name)
    else
      Rails.logger.info "Après création de Room ; création de la base #{database_name}"
      Apartment::Database.create(database_name)
    end
  end

  def destroy_db
    Rails.logger.info "Destruction de la base #{database_name}"
    Apartment::Database.drop(database_name)
  end

  


 

end
