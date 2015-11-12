# -*- encoding : utf-8 -*-

# La classe Organisme est quasiment la tête de toutes les classes du programme.
# Un organisme a des livres de recettes et de dépenses, mais aussi un livre d'OD et
# un d'A Nouveau. De même un organisme a un ou des comptes bancaires et une ou
# des caisses.
#
# Un organisme a également des exercices (Period), lesquels ont à leur tour des
# comptes.
#
# Les champs obligatoires sont le titre de l'organisme, la base de donnée associée, et
# le statut (association ou entreprise).
#
#  Précision sur la base de données : Pour faciliter les sauvegardes, chaque organisme
#  dispose de sa propre base de données (dont le nom doit bien sur être unique).
#
#  Concrètement, ce sujet est traité par la classe Room, qui est celle qui effectue
#  la création de la base (et qui en vérifie l'unicité). La mention uniqueness => true
#  pour database_name est donc ici peu utile puisqu'il ne peut y avoir qu'un seul
#  organisme par base.
#
#  Le formulaire de création demande si on choisit le statut, lequel ne peut plus être
#  modifié ensuite : actuellement deux possibilités, association ou entreprise.
#
#  La nomenclature, un Hash décrivant la construction des documents (Bilan, Compte
#  de Résultats) est également stockée à la création. Mais contrairement au statut, on
#  peut modifier une nomenclature pour importer un autre type de fichier. Le but est
#  de pouvoir adapter les éditions au cas où on ajouterait des comptes non prévus dans
#  la nomenclature fournie par défaut.
#
#  Le champ version enregistre la version qui a été utilisée pour la création de
#  l'organisme sur la base de la constante VERSION qui est dans le fichier
#  config/initializers/constant.rb
#
#  A terme cela permettra d'introduire un controller pour faire les migrations des bases qui
#  ne seraient pas à jour en terme de version.
#
#
class Organism < ActiveRecord::Base

  # attr_accessible :title, :database_name, :status, :comment, :racine

  acts_as_tenant
  has_many :periods, dependent: :destroy
  before_destroy :detruit_periods
  has_one :nomenclature, dependent: :destroy
  has_many :sectors, dependent: :destroy
  has_many :books, dependent: :destroy
  has_many :destinations, dependent: :delete_all
  has_many :natures, through: :periods
  has_many :bank_accounts, dependent: :delete_all
  has_many :bank_extracts, through: :bank_accounts
  has_many :bank_extract_lines, through: :bank_extracts
  has_many :writings, :through=>:books
  has_many :compta_lines, :through=>:writings
  has_many :check_deposits, through: :bank_accounts
  has_many :cashes, dependent: :destroy
  has_many :cash_controls, through: :cashes
  has_many :income_books, dependent: :destroy
  has_many :outcome_books, dependent: :destroy
  has_one :an_book, dependent: :destroy
  has_many :od_books, dependent: :destroy
  has_many :virtual_books # les virtual_books ne sont pas persisted? donc inutile d'avoir un callback
  has_many :accounts, through: :periods
  has_many :pending_checks, through: :accounts # est utilisé pour l'affichage du message dans le dashboard
  has_many :holders, dependent: :destroy

  # La table adherent_bridges a été mise en place pour eneregistrer les informations
  # permettant de faire le lien avec le gem adhérent.
  #
  # Cette table enregistre ainsi les données (nature, compte bancaire, caisse, livre
  # recevant les règlements)
  #
  has_one :bridge, class_name:'Adherent::Bridge', dependent: :destroy

  # liaison avec le gem adherent
  has_many :members, class_name: 'Adherent::Member', dependent: :destroy
  has_many :payments, :through=>:members, class_name:'Adherent::Payment'
  has_many :adhesions, :through=>:members, class_name:'Adherent::Adhesion'

  # gestion des masques d'écritures
  has_many :masks, dependent: :destroy
  has_many :subscriptions, :through=>:masks

  # renvoie juste les secteurs ASC et Fonctionnement d'un CE
  has_many :ce_sectors,
    -> {where "sectors.name = 'Fonctionnement' OR sectors.name = 'ASC' "},
    class_name:'Sector'

  before_validation :fill_version
  after_create :fill_children
  # sector, :fill_books, :fill_finances, :fill_destinations, :fill_nomenclature


  strip_before_validation :title, :comment, :database_name

  validates :title, presence: true, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  validates :status, presence:true, :inclusion=>{:in=>LIST_STATUS}
  validates :siren, allow_blank:true, :length=>{:is=>9}, format:/\A\d*\z/
  validates :postcode, allow_blank:true, :length=>{:within=>2..5}, format:/\A\d*\z/


  # renvoie le propriétaire de la base
  def owner
    holders.where('status = ?', 'owner').first.user
  end

  # Retourne la dernière migration effectuée pour la base de données représentant cet organisme
  def self.migration_version
    ActiveRecord::Migrator.current_version
  end


  # retourne la collection de livres de Recettes et de Dépenses
  # ceux qui sont accessibles dans la partie saisie.
  #
  # S'appuie sur le scope in_outs de books
  def in_out_books
    books.in_outs
  end

  # créé un cash_book pour chacune des caisses
  def cash_books
    cashes.map do |c|
      vb = virtual_books.new
      vb.virtual = c
      vb
    end
  end

  # créé un virtual_book pour chacun des comptes bancaires
  def bank_books
    bank_accounts.map do |ba|
      vb = virtual_books.new
      vb.virtual = ba
      vb
    end
  end

  def sectored?
    sectors.count > 1
  end

  # retourne le nombre d'exercices ouverts de l'organisme
  def nb_open_periods
    periods.opened.count
  end

  # on ne peut avoir plus de deux exercices ouverts pour chaque organisme
  def max_open_periods?
    (nb_open_periods >= 2) ? true : false
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


   # Donne le prochain numéro de pièce disponibles pour une écriture
  def next_piece_number
    mpn = writings.maximum(:piece_number)
    mpn ||= 0
    mpn.next
  end

  # renvoie les dates pour lesquelles il est possible d écrire
  # utilisé par le gem adhérent pour savoir un paiement est valide
  def range_date
    opers = periods.opened.order(:start_date)
    if opers.empty?
      return [] # permet de faire la validation avec in? dans Adherent
    else
      return opers.first.start_date..opers.last.close_date
    end
  end

  # Renvoie la caisse principale (utilisée en priorité)
  # en l'occurence actuellement la première trouvée ou nil s'il n'y en a pas
  # TODO ? à mettre dans le modèle Cash en méthode de classe par exemple ?
  # Utilisé dans le controller line pour préremplir les select.
  # utilisé également dans le form pour afficher ou non le select cash
  def main_cash_id
    cashes.any?  ? cashes.order('id').first.id  :  nil
  end

  # renvoie le compte bancaire principal, en l'occurence, le premier
  def main_bank_id
    bank_accounts.any?  ? bank_accounts.order('id').first.id  :  nil
  end



  # find_period trouve l'exercice relatif à une date donnée
  # utilisé par exemple pour calculer le solde d'une caisse à une date donnée
  # par défaut la date est celle du jour
  #
  # find_period est différent de #guess_period en ce qu'il renvoie un exercice
  # que si la date correspond à un exercice existant.
  #
  def find_period(date=Date.today)
    p = periods.where('? BETWEEN start_date AND close_date', date).first
    Rails.logger.warn "organism#find_period a été appelée avec une date pour laquelle il n y a pas d'exercice : #{date} - Organism : #{self.inspect}" if p.nil?
    p
  end

  # trouve l'exercice le plus adapté à la date demandée
  # NE RENVOIE NIL QUE S'IL N'Y A AUCUN EXERCICE (à la différence de #find_period
  # qui est plus strict.
  #
  # Sinon renvoie l'exercice le plus proche si la date est hors limite
  # ou évidemment l'exercice demandé s'il y en a un qui comprend cette date.
  #
  def guess_period(date = Date.today)
    return nil if periods.empty?
    ps = periods.order(:start_date)
    return ps.first if date < ps.first.start_date
    return ps.last if date > ps.last.close_date
    # on a traité les cas où la date demandée est hors limite
    ps.select {|p| p.start_date <= date && p.close_date >= date}.first
  end

  # recherche la pièce où est logé Organism sur la base de la similitude des
  # champs database_name de ces deux tables
#   def room
#     look_for {Room.find_by_database_name(database_name)}
#   end
#

  # la room cherche dans ses holders celui qui correspond au user demandé
  # et renvoie son statut
  def user_status(user)
    holders.where('user_id = ?', user.id).first.status
  end



  # méthode produisant le document demandé par l'argument page, avec
  # comme argument optionnel l'exercie.
  #
  # Si period est absent, renvoie le dernier exercice
  def document(page, period = Period.last)
    Compta::Nomenclature.new(period).sheet(page)
  end

  # TODO voir comment gérer les exceptions
  # remplit les éléments qui permettent de faire le pont entre le module
  # Adhérents (et plus précisément, sa partie Payment) et le PaymentObserver
  # qui écrit sur le livre des recettes.
  #
  # Cette méthode est appelée par after_create de Period pour créer les éléments du bridge
  # uniquement si le statut est association et si le bridge n'existe pas déjà.
  #
  def fill_bridge
    return unless status == 'Association'
    return if bridge
    b = build_bridge
    b.bank_account_id = bank_accounts.first.id
    b.cash_id = cashes.first.id
    b.nature_name = 'Cotisations des adhérents'
    b.destination_id = destinations.find_by_name('Adhérents').id
    b.income_book_id = income_books.first.id
    b.save!
  end


  private

  def fill_version
    self.version = FLCVERSION
  end

  def fill_children
    filler = "Utilities::Filler::#{status_class}".constantize
    filler.new(self).remplit
  end

  def detruit_periods
    periods.each do |p|
      logger.debug "Destruction de l'exercice #{p.id} de l'organisme #{p.organism_id} début : #{p.start_date}"
      p.destroy
    end
  end

  def status_class
    status == 'Comité d\'entreprise' ? 'Comite2' : status
  end

  # méthode permettant de remettre les folios et les rubriques
  # comme ils étaient à l'origine
  #
  # utilisé lors de la mise au point de ces classes
  def reset_folios
    nomenclature.folios.find_each {|f| f.destroy}
    path = File.join Rails.root, 'lib', 'parametres', status_class.downcase, 'nomenclature.yml'
    nomenclature.read_and_fill_folios(path)
  end


end
