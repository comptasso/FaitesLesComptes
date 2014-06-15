# coding: utf-8

# classe des comptes
#
# Règles : on ne peut pas modifier un numéro de compte - utilise cant_change validator
# qui est dans le fichier specific_validator
#

# Les comptes peuvent être actifs ou non. Etre actif signifie qu'on peut
# enregistrer des écritures. 

# TODO gestion des Foreign keys cf. p 400 de Agile Web Development

require 'strip_arguments' 
require 'pdf_document/simple'
require 'pdf_document/totalized'


class Account < ActiveRecord::Base
   # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold
  include Comparable

  # period_id est nécessaire car lors de la création d'un compte bancaire ou d'une caisse,
  # il faut créer des comptes en fournissant le champ period_id
  # TODO revoir ce point car on peut le gérer autrement (ie en faisant un period_id = et non un mass_assign)
  attr_accessible :number, :title, :used #, :period_id

  belongs_to :period
  belongs_to :accountable, polymorphic:true
  
  has_one :export_pdf, as: :exportable
  has_many :natures

  # les lignes sont trouvées par account_id
  has_many :compta_lines, :dependent=>:destroy
  

  # un compte peut avoir plusieurs transferts (en fait c'est limité aux comptes bancaires et caisses)
  #
  # Dans un transfer, il y a deux champs form_account_id et to_account_id. Les has_many qui suivent
  # permettent de s'y référer
  has_many :d_transfers, :as=>:to_account, :class_name=>'Transfer'
  has_many :c_transfers, :as=>:from_account, :class_name=>'Transfer'

  strip_before_validation :number, :title

  # la validator cant_change est dans le répertoire lib/validators
  validates :period_id, :title, :presence=>true
  validates :number, :presence=>true, :format=>{:with=>/\A[1-9]{1}[0-9]{1}[A-Z0-9]{0,8}\Z/}, :cant_change=>true
  validates :title, presence: true, :format=>{with:NAME_REGEX}, :length=>{:maximum=>80}
  validates_uniqueness_of :number , :scope=>:period_id
  validate :period_open
 

  default_scope order('accounts.number ASC')

  scope :classe, lambda {|i| where('number LIKE ?', "#{i}%").order('number ASC')}
  scope :classe_6, classe(6)
  scope :classe_7, classe(7)
  scope :classe_6_and_7, where('number LIKE ? OR number LIKE ?', '6%', '7%')
  scope :classe_1_to_5, where('number LIKE ? OR number LIKE ? OR number LIKE ? OR number LIKE ? OR number LIKE ?', '1%', '2%', '3%', '4%', '5%').order('number ASC')
  scope :rem_check_accounts, where('number = ?', '511')
  
  # Liste tous les comptes pour un exercice donné. Cette requête permet de limiter 
  # grandement le nombre d'interrogations de la base dans l'affichage de la vue index
  # qui a besoin de connaître pour chaque compte s'il a une nature (pour les afficher et icone supprimer) 
  # et s'il a des compta_lines (pour l'affichage de l'icone supprimer).
  scope :list_for, lambda {|period| joins("LEFT OUTER JOIN natures ON (accounts.id = natures.account_id) LEFT OUTER JOIN compta_lines ON (accounts.id = compta_lines.account_id)").
   select("accounts.id, number, title, used, COUNT(compta_lines) AS nb_cls, COUNT(natures) AS nb_nats").
   where("accounts.period_id = ?", period.id ).
   group("accounts.id") } 
  
  
 def <=>(other) 
   number <=> other.number
 end


  # le numero de compte plus le title pour les input select
  def long_name
    [number, title].join(' ')
  end


  # Surcharge de cumulated_at comme indiqué dans Utilities::Sold
  #
  # Ici nous avons une somme simple sauf dans le cas où la date est la veille de celle d'ouverture
  # ce qui se produit quand on démarre le listing d'une balance au premier jour de l'exercice
  # donc très souvent.
  #
  # Dans ce cas, le solde est un solde d'ouverture qui doit prendre en compte la ligne d'à nouveau
  def cumulated_at(date, dc)
    if date == (period.start_date - 1)
      init_sold(dc)
    else
    # TODO voir si super ne serait pas juste suffisant
    BigDecimal.new(Writing.sum(dc, :select=>'debit, credit',
      :conditions=>['date <= ? AND account_id = ?', date, id], :joins=>:compta_lines))
    end
  end
  
  # méthode redéfinie pour réduire les appels à la base de données
  def sold_at(date)
    sql = %Q(SELECT SUM(credit) AS sum_credit, SUM(debit) AS sum_debit FROM "writings" INNER JOIN "compta_lines" 
ON "compta_lines"."writing_id" = "writings"."id" WHERE (date <= '#{date}' AND account_id = #{id}))
    result = Writing.find_by_sql(sql).first
    BigDecimal.new(result.sum_credit || 0) - BigDecimal.new(result.sum_debit || 0)
  end
  

  # surcharge de accountable pour gérer le cas des remises chèques
  # il n'y a pas de table RemCheckAccount et donc on traite ce cas en premier
  # avant d'appeler super.
  def accountable
    return RemCheckAccount.new if accountable_type == 'RemCheckAccount'
    super
  end

  # Les caisse et les banques ont un nickname pour en faciliter la sélection
  # Dans les formulaires de transferts, le label_method devrait donc être accountable.nickname
  #
  # Mais visiblement, cette possibilité de délégation n'est pas prévue
  # donc je crée le nickname avec un rescue
  # au cas où le compte ne répondrait pas correctement.
  def nickname
    accountable.nickname rescue long_name
  end
  
  

  # Méthode utilisée lors de la création des comptes de caisse ou de banque
  #
  # Renvoie le numéro de compte disponible commençant par number et en incrémentant une liste
  def self.available(number)
    raise ArgumentError, 'le numéro du compte demandé doit être 53 ou 512' unless number.match(/^53$|^512$/)
    # TODO : voir pour gérer cette anomalie dans le controller au moment de la création 
    # de la caisse ou de la banque
    as = Account.where('number LIKE ?', "#{number}%").order('number ASC').last
    raise RangeError, 'Déjà 99 comptes de ce type, limite atteinte' if as && as.number.match(/\d*99$/)
    if as.nil? || as.number == number # il n'y a que le compte générique
      return number + '01'
    else
      as.number.succ
    end
  end 

  # Retourne le premier caractère du numéro de compte
  #
  # Attention classe avec un E final, il s'agit d'une logique de comptable, pas de programmeur
  def classe
    number[0]
  end

  # Donne les informations nécessaires à l'écriture d'à nouveau
  #
  # Retourne nil si solde nul, ou un hash debit, credit avec une seule valeur
  def report_info
    sa = final_sold
    if sa != 0
      sa > 0 ? {debit:0, credit:sa} : {credit:0, debit:-sa}
    end
  end

  # Donne le montant d'ouverture du compte à partir du livre d'A nouveau
  def init_sold(dc)
    anb = period.organism.an_book
    BigDecimal.new(Writing.sum(dc, :select=>dc,
        :conditions=>['book_id = ? AND account_id = ?', anb.id, id],
        :joins=>:compta_lines))
  end

# Montant du solde d'à nouveau débit
  def init_sold_debit
    init_sold('debit')
  end

  # Montant du solde d'à nouveau crédit
  def init_sold_credit
     init_sold('credit')
  end

  def final_sold
    sold_at(period.close_date)
  end

  def previous_sold
    return 0 unless previous_account
    previous_account.final_sold
  end

  def previous_account
    period.previous_account(self)
  end


  
# TODO cette méthode n'est utilisée qu'une fois pour edition de Account listing.
# la mettre ailleurs d'autant qu'il s'agit d'un sujet de présentation
#
# Montant du sole à une date donnée sous forme d'un Array [debit, credit] mais
# mis en forme avec les helpers de Rails
  def formatted_sold(date)
    [ActionController::Base.helpers.number_with_precision(cumulated_debit_before(date), precision:2),
      ActionController::Base.helpers.number_with_precision(cumulated_credit_before(date), precision:2)]
  end

 
  # Indique s'il n'y a aucune écriture sur la période concernée
  def lines_empty?(from =  period.start_date, to = period.close_date)
    compta_lines.range_date(from, to).empty?
  end

  # Indique si toutes les lignes sont locked
  def all_lines_locked?(from = period.start_date, to = period.close_date)
    compta_lines.range_date(from, to).where('locked = ?', false ).any? ? false : true
  end

  # Méthode de classe qui crée un pdf pour afficher le plan comptable
  def self.to_pdf(period)
    pdf = PdfDocument::Simple.new(period, period,
      title:"Plan comptable",
      select_method:'accounts.order(:number)',
      nb_lines_per_page:27) do |pdf|  # 27 lignes car il n'y pas de total ni de sous totel
        pdf.columns_methods = %w(number title)
        pdf.columns_widths = [20,80]
        pdf.columns_titles = %w(Numéro Libellé)
      end
    
    pdf
  end
  
  protected 
  
  def period_open
    errors.add(:base, 'Exercice clos') if period && !period.open
  end


end
