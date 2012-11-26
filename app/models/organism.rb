# -*- encoding : utf-8 -*-

class Organism < ActiveRecord::Base
  has_many :books, dependent: :destroy
  has_many :destinations, dependent: :destroy
  has_many :natures, through: :periods
  has_many :bank_accounts, dependent: :destroy
  has_many :bank_extracts, through: :bank_accounts
  has_many :bank_extract_lines, through: :bank_extracts
  has_many :writings, :through=>:books
  has_many :compta_lines, :through=>:writings
  has_many :check_deposits, through: :bank_accounts
  has_many :periods, dependent: :destroy
  has_many :cashes, dependent: :destroy
  has_many :cash_controls, through: :cashes
  has_many :income_books, dependent: :destroy
  has_many :outcome_books, dependent: :destroy
  has_one :an_book, dependent: :destroy
  has_many :od_books, dependent: :destroy
  has_many :virtual_books # les virutal_books ne sont pas persisted? donc inutile d'avoir un callback
  
  has_many :accounts, through: :periods
  has_many :archives,  dependent: :destroy
  has_many :pending_checks, through: :accounts # est utilisé pour l'affichage du message dans le dashboard
  has_many :transfers

  # jc_establish_connection lambda { database_name }
  
  after_create :create_default

  validates :title, :presence=>true
  validates :database_name, uniqueness:true, presence:true, :format=> {:with=>/^[a-z][0-9a-z]*$/, message:'format incorrect'}



  def full_name
    "#{Room.path_to_db}/#{database_name}.sqlite3"
  end


  # TODO à mettre en private après mise au point
  # TODO sera à revoir si on gère une autre base que sqlite3
  def create_db
    # création du fichier de base de données
    File.open(full_name, "w") {} # créarion d'un fichier avec le nom database.sqlite3 et fermeture
    # on établit la connection (méthode ajoutée par jcl_monkey_patch)
    if File.exist? full_name
      Rails.logger.info "Connection à la base #{database_name}"
      ActiveRecord::Base.establish_connection(
        :adapter => "sqlite3",
        :database  => full_name)
    else
      Rails.logger.warn "Tentative de connection à la base #{full_name}, fichier non trouvé"
    end
    # et on load le schéma actuel
    ActiveRecord::Base.connection.load('db/schema.rb')
    # on est maintenant en mesure de créer l'organisme
  end

  def public_books
    books.where('title != ?', 'OD')
  end

  # retourne le nombre d'exercices ouverts de l'organisme
  def nb_open_periods
    periods.where('open = ?', true).count
  end

  def max_open_periods?
    nb_open_periods >=2 ? true :false
  end

  

  # indique si organisme peut écrire des lignes de comptes, ce qui exige qu'il y ait des livres
  # et aussi un compte bancaire ou une caisse
  # Utilisé par le partial _menu pour savoir s'il faut afficher la rubrique ecrire
  def can_write_line?
    if (self.income_books.any? || self.outcome_books.any?) && (self.bank_accounts.any? || self.cashes.any?)
      true
    else
      false
    end
  end

  # vérifie qu'il y a au moins un exercice pour lequel on peut faire les comptes
  def accountable?
    periods.select {|p| p.accountable? }.any?
  end
  
  # Renvoie la caisse principale (utilisée en priorité)
  # en l'occurence actuellement la première trouvée ou nil s'il n'y en a pas
  # Utilisé dans le controller line pour préremplir les select.
  # utilisé également dans le form pour afficher ou non le select cash
  def main_cash_id
    self.cashes.any?  ? self.cashes.first.id  :  nil
  end
  
  def main_bank_id
    self.bank_accounts.any?  ? self.bank_accounts.first.id  :  nil
  end

  # find_period trouve l'exercice relatif à une date donnée
  # utilisé par exemple pour calculer le solde d'une caisse à une date donnée
  # par défaut la date est celle du jour
  def find_period(date=Date.today)
    period_array = periods.all.select {|p| p.start_date <= date && p.close_date >= date}
    if period_array.empty?
      Rails.logger.warn 'organism#find_period a été appelée avec une date pour laquelle il n y a pas d exercice'
      return nil if period_array.empty?
    end
    period_array.first
  end

  # recherche la pièce où est logé Organism sur la base de la similitude des
  # champs database_name de ces deux tables
  def room
    look_for {Room.find_by_database_name(database_name)}
  end

  
  # #look_for permet de chercher quelque chose dans la base principale
  # et de revenir dans la base de l'organisme.
  # Voir la méthode #room pour un exemple
  def look_for(&block)
    cc = ActiveRecord::Base.connection_config
    ActiveRecord::Base.establish_connection Rails.env
    yield
  ensure
    ActiveRecord::Base.establish_connection(cc)

  end

  # méthode permettant de donner le compte d'exploitation d'un organisme
  def document(page, period = Period.first)
    Compta::Nomenclature.new(period, 'nomenclature.yml').sheet(page)
  end

 
  
  private

 # crée les livres Recettes, Dépenses et OD
 # Crée également une banque et une caisse par défaut
  def create_default
    # les 3 livres
    logger.debug 'Création des livres par défaut'
    income_books.create(abbreviation:'VE', title:'Recettes', description:'Recettes')
    logger.debug  'création livre recettes'
    outcome_books.create(abbreviation:'AC', title:'Dépenses', description:'Dépenses')
    logger.debug 'creation livre dépenses'
    od_books.create(abbreviation:'OD', :title=>'Opérations diverses', description:'Op° Diverses')
    logger.debug 'creation livre OD'
    create_an_book(abbreviation:'AN', :title=>'A nouveau', description:'A nouveau')

    cashes.create(name:'La Caisse')
    logger.debug 'creation de la caisse par défaut'
    bank_accounts.create(name:'La Banque', number:'Le Numéro de Compte')
    logger.debug 'creation la banque par défaut'
  end
  
end
