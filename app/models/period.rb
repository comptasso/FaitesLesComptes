# -*- encoding : utf-8 -*-

require 'list_months' 
 

# == Schema Information
# Schema version: 20110515121214
#
# Table name: periods
#
#  id                 :integer         not null, primary key 
#  start_date         :date
#  close_date         :date
#  organism_id       :integer
#  open               :boolean         default(TRUE)
#  created_at         :datetime
#  updated_at         :datetime
#  first_active_month :integer         default(0), not null
#
#
#
# == Objectif du modèle Period
# Period correspond à un exercice. Les règles sont donc les suivantes :
# - le premier exercice créé peut avoir une durée de moins de 12 mois
# on demande donc la date de début (qui peut être n'importe quoi (mais on
# va fixer un début de mois et la date de fin qui va être une fin de mois
# à distance max de deux ans
# 
# Cela impose sa date de début et une valeur par défaut de 12 mois pour la date de
# fin.
# 
#
# La cloture d'un exercice doit être précédée des opérations de cloture.
# 
# La date de cloture doit forcément être postérieure à la date d'ouverture
#
#
# Period est l'élément central de la comptabilité. Il appartient à Organisme
# et par ce biais a accès aux livres, aux caisses et aux banques.
#
# Par ailleurs Period possède les comptes comptable et les natures qui servent à
# classer les écritures pour les productions des documents comptables.
#
# La méthode has_many :used_accounts est utilisée uniquement pour limiter
# la liste des comptes qui sont affichés dans la partie Compta->Journaux->Ecrire.
# 
#
class Period < ActiveRecord::Base 

  include Utilities::JcGraphic

  attr_accessible :start_date, :close_date
  
  # Les classes ...validator sont ici des classes spécifiques de validator pour les exercices
  # on ne les met pas dans lib/validators car elles sont réellement dédiées

  # Valide que le start_date est le lendemain du close date de l'exercice précédent
  class ContiguousValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record.previous_period? && record.previous_period.close_date != (value - 1.day)
        record.errors[attribute] << "ne peut avoir un trou dans les dates #{record.previous_period.close_date}"
      end
    end
  end

  # Valide que le close_date est bien postérieur au start_date
  class ChronoValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors[attribute] << "la date de cloture doit être postérieure à l'ouverture" if (value && (value < record.start_date))
    end
  end

 
  belongs_to :organism
  has_many :books, :through=>:organism

  has_many :accounts, :dependent=>:destroy
  has_many :used_accounts, class_name:'Account', :conditions=>{:used=>true}
  has_many :natures
  has_many :compta_lines, :through=>:accounts 
  has_one :balance, :class_name=>'Compta::Balance'
  has_one :listing, :class_name=>'Compta::Listing'
  has_one :export_pdf, as: :exportable

 
  validates :organism_id, :presence=>true
  validates :open, :cant_become_true=>true
  validates :close_date, :presence=>true,:chrono=>true, :cant_edit=>true
  validates :start_date, :presence=>true, :contiguous => true, :cant_edit=>true
  validate :should_not_exceed_24_months
  
  
  before_validation :fix_days
  before_create :should_not_have_more_than_two_open_periods
    
  after_create :create_plan, :create_bank_and_cash_accounts, :create_rem_check_accounts, :load_natures ,:unless=> :previous_period?
  after_create :copy_accounts, :copy_natures, :if=> :previous_period?
  after_create :check_nomenclature
  # TODO probablement inutile si pas asssociation
  after_create :fill_bridge 
 
  before_destroy  :destroy_writings,:destroy_cash_controls, :destroy_bank_extracts, :destroy_natures
  

  scope :opened, where('open = ?', true)
 
  # trouve l'exercice précédent en recherchant le premier exercice
  # avec la date de cloture < au start_date de l'exercice actuel
  # renvoie lui même s'il n'y en a pas
  def previous_period
    ::Period.first(:conditions=>['organism_id = ? AND close_date < ?', organism_id, start_date],
      :order=>'close_date DESC') || self
  end

  # indique s'il y a un exercice précédent en testant si previous period renvoie un exercice différent de self
  def previous_period?
    (previous_period.id == id) ? false : true
  end

  def previous_period_open?
    previous_period? && !previous_period.closed?
  end


  # trouve l'exercice suivant en recherchant l'exercice qui à la première date qui soit au dela de close_date de l'exercice actuel
  # renvoie lui même s'il n'y en a pas
  def next_period
    Period.first(:conditions=>['organism_id = ? AND start_date > ?', organism_id, close_date],
      :order=>'start_date ASC') || self
  end

  # indique s'il y a un exercice suivant en testant si l'exercice suivant est différent de lui même
  def next_period?
    next_period == self ? false : true
  end

  def first_period?
    !previous_period?
  end

  def last_period?
    !next_period?
  end
  
  def max_open_periods?
    organism.periods.opened.count >=2
  end

  # un exercice peut être détruit mais uniquement si c'est le premier ou le dernier
  def destroyable?
    first_period? || last_period?
  end

  # renvoie la liste des comptes pour deux exercices successifs.
  # to_set garantit l'unicité des comptes et sort retourne alors un Array
  def two_period_account_numbers
    if previous_period?
      previous_period.account_numbers.to_set.merge(account_numbers).sort
    else
      account_numbers
    end
  end

  # renvoie la liste des numéros de comptes de l'exercice
  def account_numbers
    accounts.map {|acc| acc.number}
  end
  
  # renvoie le compte (12) qui sert pour enregistrer le résultat de l'exercice
  def report_account
    accounts.where('number = ?', '12').first
  end

  # Renvoie le compte de l'exercice précédent
  def previous_account(account)
    return nil unless previous_period?
    previous_period.accounts.find_by_number(account.number)
  end

  

  # Les conditions pour qu'un exercice puisse être fermé sont :
  # qu'il soit ouvert
  # que tous ses journaux soit fermés
  # que l'exercice précédent soit fermé
  def closable?
    
    self.errors.add(:close, 'Exercice déja fermé') unless open
    # tous les journaux doivent être fermés
    self.errors.add(:close, "L'exercice précédent n'est pas fermé") if previous_period? && previous_period.open
    # l'exercice doit être accountable (ce qui veut dire avoir des natures et que celles ci soient toutes reliées à des comptes
    self.errors.add(:close, "Des natures ne sont pas reliées à des comptes") unless accountable?
    # toutes les lignes doivent être verrouillées
    self.errors.add(:close, "Toutes les lignes d'écritures ne sont pas verrouillées") if compta_lines.unlocked.any?
    # il faut un exercice suivant
    self.errors.add(:close, "Pas d'exercice suivant") unless next_period? 
    # il faut un livre d'OD
    self.errors.add(:close, "Il manque un livre d'OD pour passer l'écriture de report") if organism.od_books.empty?
    # il faut un compte pour le report du résultat
    self.errors.add(:close, "Pas de compte 12 pour le résultat de l'exercice") unless next_period.report_account

    errors.any? ? false : true

  end


  # indique si l'exercice est clos
  def closed?
    open ? false : true
  end

  # Effectue la clôture de l'exercice.
  #
  # La clôture de l'exercice doit effectuer une écriture de report dans le livre
  # d'OD à partir du résultat => il faut un compte report à nouveau pour mouvementer
  # le résultat de l'exercice vers le report.
  # 
  def close
    if closable?
      next_p = next_period
      an_book = organism.books.find_by_type('AnBook')
      date = next_p.start_date

      Period.transaction do
        
        w = an_book.writings.new(date:date, narration:'A nouveau')
        # on fait d'abord les compta_liens du compte de bilan
        report_comptes_bilan.each { |cl| w.compta_lines << cl }
        
        
        # puis on intègre la compta_line de report à nouveau
        w.compta_lines << report_a_nouveau if resultat != 0.0
         
        unless w.valid?
          logger.warn  'Dans period#close avec des erreurs sur w'
          logger.warn  w.errors.messages
          w.compta_lines.each { |cl| logger.warn(cl.inspect) unless cl.valid?}
          return false
        end
        
        if w.save
          logger.info 'Clôture de l\'exercice effectuée'
          # finir la transaction en verrouillant l'exercice
          update_attribute(:open, false)
          
        else
          logger.info "Une erreur s'est produite lors de la clôture #{w.inspect}"
          return false
        end
      end
    end
    # retourne true ou false correspondant à la situation de l'exercice
    return closed?
  end

 

  

  # renvoie le total des comptes commenaçnt par n
  def total_classe(n, dc)
    compta_lines.classe(n).sum(dc)
  end

  # renvoie le solde des comptes de la classe transmis en argument.
  #
  # Applique round(2) au résultat du calcul pour éviter les nombres approchés
  def sold_classe(n)
    (total_classe(n, 'credit')- total_classe(n, 'debit')).round(2)
  end

  def resultat
    sold_classe(7) + sold_classe(6)
  end

  # TODO a retirer puisque ces informations sont désormais fournies par Sector
  # revoie la liste des comptes commençant par 512
  def list_bank_accounts
    accounts.where('number LIKE ?', '512%')
  end

  # renvoie la liste des comptes commençant par 53
  def list_cash_accounts
    accounts.where('number LIKE ?', '53%')
  end

  # renvoie les comptes correspondant aux remises de chèques (511)
  # retourne un Arel
  #
  # A priori, il ne doit y en avoir qu'un
  def rem_check_accounts
    accounts.where('number = ?', REM_CHECK_ACCOUNT[:number])
  end
  
  # renvoie le premier (et normalement l'unique) compte de remise de chèque
   def rem_check_account
    rem_check_accounts.first
  end



  # renvoie un array de tous les comptes de classe 7
  def recettes_accounts
    accounts.classe_7
  end


  # renvoie un array de tous les comptes de classe 6
  def depenses_accounts
    accounts.classe_6 
  end

  # renvoie un array de toutes les natures de type recettes
  def recettes_natures
    natures.recettes
  end
  
  def nature_name_exists?(name)
    natures.find_by_name(name) ? true : false
  end

  # renvoie un array de toutes les natures de types dépenses
  def depenses_natures
    natures.depenses
  end
 
  # le nombre de mois de l'exercice
  #
  # également disponible sous #length
  def nb_months
    (close_date.year * 12 + close_date.month) - (start_date.year * 12 + start_date.month) + 1
  end

  alias :length  :nb_months

    
  # list_months renvoye un tableau d'instance de mois (MonthYear)
  # permettant notamment de faire les entêtes de vues listant les
  # mois de l'exercice
  def list_months
    ListMonths.new(start_date, close_date)
  end

  # renvoie un array de Compta::MonthlyLedger correspondant aux mois de
  # l'exercice
  def monthly_ledgers
    list_months.map {|my| Compta::MonthlyLedger.new(self, my)}
  end

  # méthode permettant de savoir si une date est un début d'exercice
  #
  # Cette méthode est utilisée par monthly_value dans Utilities::Sold
  def self.beginning_of_period?(date)
    date.in? Period.all.collect(&:start_date)
  end

  # permet d'indiquer l'exercice sans le mot Exercice,
  # par exemple 2012 au lieu de Exercice 2012. 
  # Utilisé dans le titre général et dans les graphiques
  def short_exercice
    r=''
    # année civile
    if self.start_date==self.start_date.beginning_of_year && self.close_date == self.start_date.end_of_year
      r << self.start_date.year.to_s
    elsif self.start_date.year == self.close_date.year # on n'est pas sur une année civile mais dans la même année
      r << (I18n::l self.start_date, :format=>'%b')
      r << ' à ' << (I18n::l self.close_date, :format=>:short_month_year)
    else
      r << (I18n::l self.start_date, :format=>:short_month_year)
      r << ' à ' << (I18n::l self.close_date, :format=>:short_month_year)
    end
    r
  end
  
  # long exercice rajoute Exercice si on est dans un texte court par exemple
  # 2013 ou Exercice\n si on est dans un texte plus long par exemple
  # Exercice\n mai à juin 2014
  def long_exercice
    text = short_exercice
    if text.length < 5 # c'est le cas d'une année simple; 2013 par exemple
      "Exercice #{text}"
    else
      "Exercice \n#{text}"
    end
  end
  
  # permet d'indiquer l'exercice sous la forme d'une chaine de caractère
  # du type Exercice 2011 si period correspond à une année pleine
  # ou de Mars 2011 à Février 2012 si c'est à cheval sur l'année civile.
  def exercice
    Rails.logger.warn 'Exercice is deprecated, utiliser long_exercice à la place'
    long_exercice
  end

  # retourne une chaîne de caractère adaptée en fonction des différents cas de figure
  # Utilisé notamment dans la production des pdf.
  #
  # Renvoie une chaîne vide s'il n'y a pas d'exercice précédent
  def previous_exercice
    previous_period? ? previous_period.short_exercice : ''
  end
  
  # renvoie le mois le plus adapté pour un exercice
  #   si la date du jour est au sein de l'exercice, renvoie le mois correspondant
  #   si la date du jour est avant l'exercice, renvoie le premier mois
  #   si elle est après, renvoie le dernier mois
  #
  def guess_month(date=Date.today)
    date = start_date if date < start_date
    date = close_date if date > close_date
    MonthYear.from_date(date) 
  end
  
  # renvoie le mois le plus adapté à partir d'un Hash structuré comme un MonthYear
  # h[:year] et h[:month]
  def guess_month_from_params(h)
    Date.civil(h[:year].to_i, h[:month].to_i)
    guess_month(Date.civil(h[:year].to_i, h[:month].to_i))
  end

  # renvoie la date la plus adaptée pour un exercices
  #   si la date du jour est au sein de l'exercice, renvoie cette date
  #   si la date du jour est avant l'exercice, renvoie le premier jour de l'exeercice
  #   si elle est après, renvoie le dernier jour de l'exercice
  def guess_date
    d = Date.today
    d = start_date if d < start_date
    d = close_date if d > close_date
    d
  end


 

  # permet de renvoyer la liste des mois de l'exercice correspondant à un mois spécifique
  # généralement un seul mais il peut y en avoir deux en cas d'exercice de plus d'un an
  #
  # l'argument month est de type string et avec deux chiffres par exemple '04'
  def find_month(month)
    month = month.to_s if month.is_a?(Numeric)
    month = '0' + month if month.length == 1
    list_months.select {|my| my.month == month}
  end

  




  # indique s'il y a un mois correspondant au mois demandé.
  #
  # L'argument month est de type string et avec deux chiffres par exemple '04'
  def include_month?(month)
    !find_month(month).empty?
  end

  # find_first_month permet de renvoyer le premier mois correspondant au mois demandé
  # Il peut en effet y avoir deux mois correspondant si l'exercice est de plus de 12 mois.
  #
  # L'argument month est de type string et avec deux chiffres par exemple '04'
  def find_first_month(month)
    ms = find_month(month)
    ms.first unless ms.empty?
  end

 
  

  # informe si toutes les natures sont bien reliées à un compte
  def all_natures_linked_to_account?
    natures.without_account.empty? 
  end

  # boolean : indique si l'on peut faire de la comptabilité
  # Il faut des natures et que toutes ces natures soient reliées à des comptes
  # TODO : ajouter aussi que l'exercice ne doit pas être fermé
  def accountable?
    return false if natures.empty?
    all_natures_linked_to_account?
  end

 


  protected
 
  # report_compta_line crée la ligne de report de l'exercice
  def report_a_nouveau
    res_acc  = next_period.report_account
    ran = ComptaLine.new(account_id:res_acc.id, credit:resultat, debit:0)
    Rails.logger.warn 'report à nouveau invalide' unless ran.valid?
    ran
  end

 
  # Pour les comptes de classe 1 à 5
  # crée un tableau de compta_lines reprenant le solde du compte
  def report_comptes_bilan
    rcb = []
    # POur le comptes de classe 1 à 5
    np = next_period
    accounts.find_each(conditions:['number < ?', '5Z']) do |acc|
      # on trouve le compte correspondant
      next_acc = np.accounts.find_by_number(acc.number)
      # et on créé une compta_line respectant les principes
      h = acc.report_info # récupération des infos du compte
      # pas de compta_line s'il n'y a pas de mouvement
      if h
        rcb << ComptaLine.new(account_id:next_acc.id,
          debit:h[:debit],
          credit:h[:credit])
      end
    end

    return rcb
  end

   

  def should_not_have_more_than_two_open_periods
    if max_open_periods?
      self.errors.add(:base, "Impossible d'avoir plus de deux exercices ouverts")
      return false
    end
     
  end

  def should_not_exceed_24_months
    duree = close_date - start_date rescue nil
    if duree && duree > 731
      self.errors.add(:close_date, 'un exercice ne peut avoir plus de deux ans')
      return false
    end
  end

  # permet de s'assurer que les dates d'ouverture et de clôture
  # sont respectivement des dates de début et de fin de mois.
  def fix_days
    self.start_date = start_date.beginning_of_month if start_date
    self.close_date = close_date.end_of_month if close_date
  end

  private

  # TODO vraiment pas terrible de voir que Period doit solliciter organism.send(:status_class)
  def create_plan
    Utilities::PlanComptable.create_accounts(self, organism.send(:status_class))
  end

  def create_bank_and_cash_accounts
    # organisme a créé une banque et une caisse par défaut et il faut leur créer des comptes
    # utilisation de send car create_accounts est une méthode protected
    organism.bank_accounts.each {|ba| ba.send(:create_accounts)}
    organism.cashes.each {|c| c.send(:create_accounts)}
    accounts(true) # pour mettre à jour la relation avec les comptes
    # sinon une création et une destruction dans la foulée (cas des tests) laisse une trace de ces deux comptes
  end
  
  # crée le compte de remise de chèques
  # TODO faire spec d'intégration
  def create_rem_check_accounts
      accounts.create!(REM_CHECK_ACCOUNT)
  end
  
 

  # demande à PlanComptable de recopier les comptes de l'exercice précédent
  #
  def copy_accounts
    Utilities::PlanComptable.new(self, 'statut').copy_accounts(previous_period)
  end

  # recopie les natures de l'exercice précédent 's'il y en a un)
  def copy_natures
    pp = self.previous_period
    pp.natures.all.each do |n|
      nn = {name: n.name, comment: n.comment, book_id: n.book_id} # on commence à construire le hash
      if n.account_id # cas où il y avait un rattachement à un compte
        previous_account=pp.accounts.find(n.account_id) # on identifie le compte de rattachement
        nn[:account_id] = self.accounts.find_by_number(previous_account.number).id # et on recherche son correspondant dans le nouvel exercice
      end
      self.natures.create!(nn) # et on créé maintenant une nature avec les attributs qui restent
    end
  end
  
  # Destiné à rendre persistant la vérification que la nomenclature est OK, ceci 
  # pour éviter d'avoir à faire cette vérification à chaque usage de la nomenclature
  # 
  # period_coherent? enregistre son resultat dans le champ de nomenclature_ok
  # 
  def check_nomenclature
    organism.nomenclature.period_coherent?(self)
  end

  # load natures est appelé lors de la création d'un premier exercice
  # load_natures lit le fichier natures_asso.yml et crée les natures correspondantes
  # retourne le nombre de natures
  #
  # TODO améliorer la gestion d'une éventuelle erreur
  # TODO voir aussi si on ne peut utiliser une classe similaire à Utilities::PlanComtpable pour simplifier
  # copy_natures et load_natures et retirer de cette clase également load_file_natures. On pourrait aussi envisager de passer ces callbacks dans un Observer.
  def load_natures  
    Rails.logger.debug 'Création des natures'
    nats = load_file_natures
    books = collect_books(nats)
    nats.each do |n|
      a = accounts.find_by_number(n[:acc]) 
       nat = natures.new(name:n[:name], comment:n[:comment], account:a)
       nat.book_id = books[n[:book]] 
       puts "#{nat.name} - #{nat.errors.messages}" unless nat.valid?
       nat.save
    end
    natures(true).count
  end
  
  protected
  
  # fait la collecte des livres qui sont nécessaires à la création des natures
  def collect_books(natures)
    livres = natures.collect {|n| n[:book]}.uniq
    hash_books = {}
    livres.each do |b|
      hash_books[b] = organism.books.where('title = ?', b).first.id
    end
    hash_books
  end

  def load_file_natures(source = nil)
    source = "#{Rails.root}/app/assets/parametres/#{organism.send(:status_class).downcase}/natures.yml"
    YAML::load_file(source)
  rescue
    logger.warn "Erreur dans le chargement du fichier #{source}"
    []
  end
  
   # TODO voir comment gérer les exceptions
  # remplit les éléments qui permettent de faire le pont entre le module 
  # Adhérents (et plus précisément, sa partie Payment) et le PaymentObserver
  # qui écrit sur le livre des recettes.
  def fill_bridge
    organism.fill_bridge
  end

  # TODO voir à réintroduire organism dans les callbacks de destroy au cas où
  # on reviendrait à une seule base de données.
  
  # supprime les extraits bancaires 
  # avant la destruction d'un exercice
  #
  # TODO voir si on peut se passer de la requête sql; actuellement cela bloque
  # probablement par le verrouillage qu'il y a sur l'une ou l'autre des tables
  # A revoir après modification de la logique des bank_extract_lines_lines
  #
  def destroy_bank_extracts
    organism.bank_accounts.each do |ba|
      ba.bank_extracts.period(self).each {|be| be.destroy }
    end
  end

  # supprime les controles de caisse
  # avant la destruction d'un exercice
  #
  def destroy_cash_controls
    Cash.all.each do |ca|
      ca.cash_controls.for_period(self).each {|cc| cc.destroy }
    end
  end

  # suppression des écritures et des remises de chèques
  def destroy_writings
    Writing.period(self).each do |w|
      w.compta_lines.each {|cl| cl.delete }
      w.check_deposit.delete if w.is_a? CheckDepositWriting
      w.destroy
    end
  end

  # suppression des natures
  def destroy_natures
    natures.each { |n| n.delete} 
  end

 
end
