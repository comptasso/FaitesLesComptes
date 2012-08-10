# -*- encoding : utf-8 -*-

class Organism < ActiveRecord::Base
  has_many :books, dependent: :destroy
  has_many :destinations, dependent: :destroy
  has_many :natures, through: :periods
  has_many :bank_accounts, dependent: :destroy
  has_many :bank_extracts, through: :bank_accounts
  has_many :bank_extract_lines, through: :bank_extracts
  has_many :lines, :through=>:books
  has_many :check_deposits, through: :bank_accounts
  has_many :periods, dependent: :destroy
  has_many :cashes, dependent: :destroy
  has_many :cash_controls, through: :cashes
  has_many :income_books, dependent: :destroy
  has_many :outcome_books, dependent: :destroy
  has_many :od_books, dependent: :destroy
  has_many :accounts, through: :periods
  has_many :archives,  dependent: :destroy
  has_many :pending_checks, through: :books
  has_many :transfers


  
  after_create :create_default

  validates :title, :presence=>true
  validates :database_name, uniqueness:true, presence:true, :format=> {:with=>/^[a-z]*$/, message:'format incorrect'}

  def base_name
    "db/#{database_name}.sqlite3"
  end


  # TODO à mettre en private après mise au point
  def build_room
    
    File.open(base_name, "w") {} # créarion d'un fichier avec le nom database.sqlite3 et fermeture
    # on établit la connection
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => base_name)
    # et on load le schéma actuel
    ActiveRecord::Base.connection.load('db/schema.rb')
    # on devrait alors pouvoir créer l'organisme

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

  def number_of_non_deposited_checks
    self.lines.non_depose.count
  end

  def value_of_non_deposited_checks
    self.lines.non_depose.sum(:credit)
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
    period_array = self.periods.all.select {|p| p.start_date <= date && p.close_date >= date}
    if period_array.empty?
      Rails.logger.warn 'organism#find_period a été appelée avec une date pour laquelle il n y a pas d exercice'
       return nil if period_array.empty?
    end
    period_array.first
  end

  # ActiveRecord::Base.restore est définie dans restore_record.rb
  def self.restore(new_attributes)
    Organism.skip_callback(:create, :after ,:create_default)
    new_attributes[:description] = "Restauration du #{I18n.l(Time.now)} - #{new_attributes[:description]}"
     super
  ensure
    Organism.set_callback(:create, :after, :create_default)
  end

  
  private

  def create_default
    logger.debug 'Création des livres par défaut'
    self.income_books.create(:title=>'Recettes', :description=>'Livre des recettes')
    logger.debug  'création livre recettes'
    self.outcome_books.create(title: 'Dépenses', description: 'Livre des dépenses')
    logger.debug 'creation livre dépenses'
    self.od_books.create(:title=>'OD', description: 'Opérations Diverses')

  end
  
end
