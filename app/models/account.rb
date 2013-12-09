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
  # TODO revoir ce point car on peut le gérer autrement
  attr_accessible :number, :title, :used, :period_id

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
  # TODO peut être rajouter un :conditions sur la classe 5 du compte
  has_many :d_transfers, :as=>:to_account, :class_name=>'Transfer'
  has_many :c_transfers, :as=>:from_account, :class_name=>'Transfer'

  strip_before_validation :number, :title

  # la validator cant_change est dans le répertoire lib/validators
  validates :period_id, :title, :presence=>true
  validates :number, :presence=>true, :format=>{:with=>/\A[1-9]{1}[0-9]{1}[A-Z0-9]{0,8}\Z/}, :cant_change=>true
  validates :title, presence: true, :format=>{with:NAME_REGEX}, :length=>{:maximum=>80}
  validates_uniqueness_of :number, :scope=>:period_id

  # TODO être sur que period est valide (par exemple on ne doit pas
  # pouvoir ouvrir ou modifier un compte d'un exercice clos

  default_scope order('number ASC')

  scope :classe, lambda {|i| where('number LIKE ?', "#{i}%").order('number ASC')}
  scope :classe_6, classe(6)
  scope :classe_7, classe(7)
  scope :classe_6_and_7, where('number LIKE ? OR number LIKE ?', '6%', '7%')
  scope :classe_1_to_5, where('number LIKE ? OR number LIKE ? OR number LIKE ? OR number LIKE ? OR number LIKE ?', '1%', '2%', '3%', '4%', '5%').order('number ASC')
  scope :rem_check_accounts, where('number = ?', '511')
  
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
    Writing.sum(dc, :select=>'debit, credit',
      :conditions=>['date <= ? AND account_id = ?', date, id], :joins=>:compta_lines).to_f
    # to_f est nécessaire car quand il n'y a aucune compa_lines, le retour est '0'
    # et non 0 ce qui pose des difficultés pour les additions
    end
  end
  
  def sold_at(date)
    sql = %Q(SELECT SUM(credit) AS sum_credit, SUM(debit) AS sum_debit FROM "writings" INNER JOIN "compta_lines" 
ON "compta_lines"."writing_id" = "writings"."id" WHERE (date <= '#{date}' AND account_id = #{id}))
    result = Writing.find_by_sql(sql).first
    (result.sum_credit.to_f - result.sum_debit.to_f).round 2
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
    as = Account.where('number LIKE ?', "#{number}%").order('number ASC')
    # FIXME : voir à quoi sert as.last.number == '53'
    # probablement inutile depuis qu'on crée une banque et une caisse par déafaut
    if as.empty? || as.last.number == '53'
      return number + '01'
    else
      # il faut prendre le nombre trouvé, vérifier qu'il ne se termine
      # pas par 99, le transformer en chiffre, y ajouter 1 et le transformer en string
      n = as.last.number
      # FIXME : voir pour gérer cette anomalie plus élégamment
      raise 'Déja 99 comptes de ce type, limite atteinte' if n =~ /99$/
      m = n.to_i; m = m + 1;
      return m.to_s
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
    Writing.sum(dc, :select=>dc, :conditions=>['book_id = ? AND account_id = ?', anb.id, id], :joins=>:compta_lines).to_f
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


end
