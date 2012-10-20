# coding: utf-8

# classe des comptes
#
# Règles : on ne peut pas modifier un numéro de compte - utilise cant_change validator
# qui est dans le fichier specific_validator
#

# Les comptes peuvent être actifs ou non. Etre actif signifie qu'on peut
# enregistrer des écritures. Ainsi les comptes 10, 20 ...
# ne doivent a priori pas être actifs. Dans la vue index, ils sont en gris et en gras.



# TODO gestion des Foreign keys cf. p 400 de Agile Web Development 


class Account < ActiveRecord::Base
   # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold


  require 'pdf_document/base'

  belongs_to :period
  belongs_to :accountable, polymorphic:true
  has_many :natures

  # les lignes sont trouvées par account_id
  has_many :compta_lines
  

  # les lignes sont trouvées par counter_account_id
  has_many :counterlines, :foreign_key=>'counter_account_id', :class_name=>'Line'

  # un compte a plusieurs transferts (en fait c'est limité aux comptes bancaires et caisses)
  # TODO peut être rajouter un :conditions
  has_many :d_transfers, :as=>:to_account, :class_name=>'Transfer'
  has_many :c_transfers, :as=>:from_account, :class_name=>'Transfer'

  # la validator cant_change est dans le répertoire lib/validators
  validates :period_id, :title, :presence=>true
  validates :number, :presence=>true, :format=>{:with=>/\A[1-9]{1}[0-9]{1}[A-Z0-9]{0,8}\Z/}, :cant_change=>true
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

  # le numero de compte plus le title pour les input select
  def long_name
    [number, title].join(' ')
  end

  # méthode principale et mère des autres méthodes cumulated_credit
  # surcharger cette méthode dans les classes utilisant ce module
  # pour modifier le fonctionnement.
  def cumulated_at(date, dc)
    Writing.sum(dc, :select=>'debit, credit', :conditions=>['date <= ? AND account_id = ?', date, id], :joins=>:compta_lines).to_f
    # to_f est nécessaire car quand il n'y a aucune compa_lines, le retour est '0' et non 0 ce qui pose des
  end


  # surcharge de accountable pour gérer le cas des remises chèques
  # il n'y a pas de table RemCheckAccount et donc on traite ce cas en premier
  # avant d'appeler super.
  def accountable
    return RemCheckAccount.new if accountable_type == 'RemCheckAccount'
    super
  end

  # renvoie le compte disponible commençant par number et en incrémentant une liste 
  # avec le nombre de chiffres donnés par précision
  def self.available(number)
    as = Account.where('number LIKE ?', "#{number}%").order('number ASC')
    if as.empty?
      return number + '01'
    else
      # il faut prendre le nombre trouvé, vérifier qu'il ne se termine
      # pas par 99, le transformer en chiffre, y ajouter 1 et le transformer en string
      n = as.last.number
      raise 'Déja 99 comptes de ce type, limite atteinte' if n =~ /99$/
      m = n.to_i; m = m + 1;
      return m.to_s
    end
  end 

  # retourne le premier caractère du numéro de compte
  # attention classe avec un E final, il s'agit d'une logique de comptable, pas de programmeur
  def classe
    number[0]
  end

  # donne le montant débit d'ouverture du compte
  # s'il n'y a pas d'exercice précédent et pas de report à nouveau, c'est zero
  # s'il y a un exercice précédent clos, c'est le report à nouveau
  # s'il y a un exercice précédent non clos, c'est le solde du même compte
  def init_sold_debit
     anb = period.organism.an_book
     val =  Writing.sum('debit', :select=>'debit', :conditions=>['book_id = ? AND account_id = ?', anb.id, id], :joins=>:compta_lines).to_f
    if period.previous_period_open? 
     pp = period.previous_period # pp pour previous_period
      pacc = pp.accounts.find_by_number(number) #pacc pour previous_account
      val += pacc.cumulated_debit_at(pp.close_date) if pacc
    end
    val
  end

  def init_sold_credit
      anb = period.organism.an_book
      val = Writing.sum('credit', :select=>'credit', :conditions=>['book_id = ? AND account_id = ?', anb.id, id], :joins=>:compta_lines).to_f
    if period.previous_period_open? 
      pp = period.previous_period # pp pour previous_period
      pacc = pp.accounts.find_by_number(number) #pacc pour previous_account
      val += pacc.cumulated_credit_at(pp.close_date) if pacc
    end
    val
  end

  def formatted_sold(date)
    ['%0.2f' % cumulated_debit_before(date), '%0.2f' % cumulated_credit_before(date) ]
  end

  # TODO on pourrait utiliser le scope range_date de lines
  # calcule le total des lignes de from date à to (date) inclus dans le sens indiqué par dc (debit ou credit)
  # Exemple movement(Date.today.beginning_of_year, Date.today, true) pour un credit
  def movement(from, to, dc)
    Writing.sum(dc, :select=>'debit, credit', :conditions=>['date >= ? AND date <= ? AND account_id = ?', from, to, id], :joins=>:compta_lines).to_f
  end



  def lines_empty?(from =  period.start_date, to = period.close_date)
    compta_lines.range_date(from, to).empty?
  end
  
  def all_lines_locked?(from = period.start_date, to = period.close_date)
    compta_lines.range_date(from, to).where('locked == ?', false ).any? ? false : true
  end

  # Méthode de classe qui affiche le plan comptable
  def self.to_pdf(period)
    load 'lib/pdf_document/simple.rb'
    pdf = PdfDocument::Simple.new(period, period,
      title:"Plan comptable")
    pdf.select_method= 'accounts.order(:number)'
    pdf.set_columns %w(number title)
    pdf.set_columns_widths [20, 80]
    pdf.set_columns_titles %w(Numéro Libellé)
    pdf.set_columns_alignements [:left, :left]
    pdf
  end





end
