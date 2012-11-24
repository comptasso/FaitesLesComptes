# -*- encoding : utf-8 -*-

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
# OK un exercice créé est automatiquement le suivant du dernier exercice.
# Cela impose sa date de début et une valeur par défaut de 12 mois pour la date de
# fin.
# OK un exercice clos ne peut être réouvert
# OK il ne peut y avoir que deux exercices ouverts à la fois.
#
# OK la création d'un exercice doit enchainer sur la création des journaux
# TODO faire les oéprations de clôture.
# - la cloture d'un exercice doit être précédée des opérations de cloture.
# OK la date de cloture doit forcément être postérieure à la date d'ouverture
#
#


require 'list_months'

class Period < ActiveRecord::Base

  include Utilities::JcGraphic

 
  # Les classes ...validator sont des classes spécifiques de validator pour les exercices

  # TODO voir à mettre ces validators dans lib/validators

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
      record.errors[attribute] << "la date de cloture doit être postérieure à l'ouverture" if value < record.start_date
    end
  end

 
  belongs_to :organism
  has_many :books, :through=>:organism

  has_many :accounts, :dependent=>:destroy
  has_many :natures,  :dependent=>:destroy
  has_many :compta_lines, :through=>:accounts
  has_one :balance, :class_name=>'Compta::Balance'
  has_one :listing, :class_name=>'Compta::Listing'

 
  validates :organism_id, :presence=>true

  # TODO revoir les validations
  validates :close_date, :presence=>true,:chrono=>true
  validates :start_date, :presence=>true,:contiguous => true

  

  # TODO revoir ces call_backs en utilisant des conditions de type :if
  # TODO changer le update should not reopen en utilisant un des validate
  before_update :fix_days, :cant_change_start_date, :should_not_reopen
  before_create :should_not_have_more_than_two_open_periods, :fix_days
  before_save :should_not_exceed_24_months, 
    :cant_change_close_date_if_next_period
  #
  # 
  #
  after_create :create_plan, :create_bank_and_cash_accounts, :load_natures ,:unless=> :previous_period?
  after_create :copy_accounts, :copy_natures, :if=> :previous_period?
 

  # TODO voir la gestion des effacer dans les vues et dans le modèle. 

  # TODO mettre dans la migration que start_date et close_date sont obligatoires
 
  # trouve l'exercice précédent en recherchant le premier exercice
  # avec la date de cloture < au start_date de l'exercice actuel
  # renvoie lui même s'il n'y en a pas
  def previous_period
    ::Period.first(:conditions=>['organism_id = ? AND close_date < ?', self.organism_id, self.start_date],
      :order=>'close_date DESC') || self
  end

  # indique s'il y a un exercice précédent en testant si previous period renvoie un exercice différent de self
  def previous_period?
    (previous_period.id == self.id) ? false : true
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

  def two_period_account_numbers
    if previous_period?
      pp = previous_period
      acc_list = pp.account_numbers
      (acc_list + account_numbers).uniq!.sort
    else
      account_numbers
    end
  end

  # renvoie la liste des numéros de comptes de l'exercice
  def account_numbers
    accounts.map {|acc| acc.number}
  end
  
  # renvoie le compte (120) qui sert pour enregistrer le résultat positif de l'exercice
  # ou 129 pour enregistrer le résultat négatif
  def report_account
    accounts.where('number = ?', 12).first
  end

  def pave_char
    ['result_pave', 'result']
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
    self.errors.add(:close, "Il manque un livre d'OD pour passer l'écriture de report") unless organism.books.find_by_type('OdBook')
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
  #  La clôture de l'exercice doit effectuer une écriture de report dans le livre
  #  d'OD à partir du résultat => il faut un compte report à nouveau pour mouvementer
  #  le résultat de l'exercice vers le report.
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

  # report_compta_line crée la ligne de report de l'exercice
  # TODO traiter le cas où le résultat serait zéro
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

  # renvoie le total des comptes commenaçnt par n
  def total_classe(n, dc)
    compta_lines.classe(n).sum(dc)
  end
  
  def sold_classe(n)
    total_classe(n, 'credit') - total_classe(n, 'debit')
  end

  def resultat
    sold_classe(7) + sold_classe(6)
  end



  def list_bank_accounts
    accounts.where('number LIKE ?', '512%')
  end
  
  def list_cash_accounts
    accounts.where('number LIKE ?', '53%')
  end

  def rem_check_accounts
    accounts.where('number = ?', REM_CHECK_ACCOUNT[:number])
  end

  def recettes_accounts
    accounts.classe_7.all
  end

  # rem_check_account retourne le compte de Chèques à l'encaissement
  # ou le créé s'il n'existe pas.
  # Pour le créer, il s'appuie sur la constante REM_CHECK_ACCOUNT qui est dans
  # le fichier constants.rb
  def rem_check_account
    as =  accounts.find_by_number(REM_CHECK_ACCOUNT[:number])
    as ? as : accounts.create!(REM_CHECK_ACCOUNT)
  end



  def depenses_accounts
    accounts.classe_6.all 
  end

  def recettes_natures
    natures.recettes.all
  end

  def depenses_natures
    natures.depenses.all
  end
 
  
  def nb_months
    (close_date.year * 12 + close_date.month) - (start_date.year * 12 + start_date.month) + 1
  end

  alias :length  :nb_months

    
  # list_months renvoye un tableau d'instance de mois (MonthYear)
  # utilisée notamment par Book#monthly_datas
  def list_months
    ListMonths.new(start_date, close_date)
  end

 


  # permet d'indiquer l'exercice sous la forme d'une chaine de caractère
  # du type Exercice 2011 si period correspond à une année pleine
  # ou de Mars 2011 à Février 2012 si c'est à cheval sur l'année civile.
  def exercice
    r=''
    # année civile
    if self.start_date==self.start_date.beginning_of_year && self.close_date == self.start_date.end_of_year
      r= 'Exercice ' << self.start_date.year.to_s
    elsif self.start_date.year == self.close_date.year # on n'est pas sur une année civile mais dans la même année
      r << (I18n::l self.start_date, :format=>'%b')
      r << ' à ' << (I18n::l self.close_date, :format=>:short_month_year)
    else
      r << (I18n::l self.start_date, :format=>:short_month_year)
      r << ' à ' << (I18n::l self.close_date, :format=>:short_month_year)
    end
    r
  end
  
  # renvoie le mois le plus adapté pour un exercice
  # si la date du jour est au sein de l'exercice, renvoie le mois correspondant
  # si la date du jour est avant l'exercice, renvoie le premier mois
  # si elle est après, renvoie le dernier mois
  #
  def guess_month(date=Date.today)
    date = start_date if date < start_date
    date = close_date if date > close_date
    MonthYear.new :month=>date.month, :year=>date.year
  end

  # renvoie la date la plus adaptée pour un exercices
  # si la date du jour est au sein de l'exercice, renvoie cette date
  # si la date du jour est avant l'exercice, renvoie le premier jour de l'exeercice
  # si elle est après, renvoie le dernier jour de l'exercice
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

 
  # donne les soldes de chaque mois, est appelé par le module JcGraphic pour constuire les graphes
  # TODO voir s'il faut vraiment books.all (donc avec l'OD) ou sans l'OD
  def monthly_value(date)
    books.all.sum {|b| b.monthly_value(date) }
  end


  def create_account_from_file(source)
    pc= Utilities::PlanComptable.new
    pc.create_accounts(self.id, source)
  end

  # informe si toutes les natures sont bien reliées à un compte
  def all_natures_linked_to_account?
    natures.without_account.empty? 
  end

  # boolean : indique si l'on peut faire de la comptabilité
  # Il faut des natures et que toutes ces natures soient reliées à des comptes
  def accountable?
    return false if natures.empty?
    all_natures_linked_to_account?
  end

  def array_natures_not_linked
    natures.without_account.all
  end


  protected


   # report_compta_line crée la ligne de report de l'exercice
  # TODO traiter le cas où le résultat serait zéro
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

  # on ne peut jamais changer la date de début d'un exercice créé.
  # soit c'est le premier et la date de début a été fixée lors de la création
  # de la organism
  # soit ce n'est pas le premier et il est lié à l'exercice précédent
  # TODO revoir ces deux fonctions.
  def cant_change_start_date
    if self.changed_attributes['start_date'] 
      self.errors.add(:start_date, "Impossible de changer la date d'ouvrture d'un exercice suivant")
      return false 
    end
  end

  # on ne peut pas changer la date de clôture si l'exercice suivant a déja été créé
  # TODO voir si on ne pourrait pas assouplir la règle
  def cant_change_close_date_if_next_period
    if self.changed_attributes['close_date'] && next_period
      self.errors.add(:close_date, 'Impossible de changer la date de cloture avec un exercice suivant')
      return false 
    end
  end

  # TODO à transformer en validate (comme pour les autres modèles)
  def should_not_reopen
    if self.changed_attributes["open"] == false
      self.errors.add(:open, 'Impossible de réouvrir un exercice clos')
      return false 
    end
  end

  def should_not_have_more_than_two_open_periods
    if organism.nb_open_periods >= 2
      self.errors.add(:base, "Impossible d'avoir plus de deux exercices ouverts")
      return false
    end
     
  end

  def should_not_exceed_24_months
    if self.close_date - self.start_date > 731
      self.errors.add(:close_date, 'un exercice ne peut avoir plus de deux ans')
      return false
    end
  end

  def fix_days
    self.start_date=self.start_date.beginning_of_month
    self.close_date=self.close_date.end_of_month
  end

  private

  def create_plan
    Utilities::PlanComptable.new.create_accounts(id, 'asso/plan_comptable.yml')
  end

  def create_bank_and_cash_accounts
    # organisme a créé une banque et une caisse par défaut et il faut leur créer des comptes
    # utilisation de send car create_accounts est une méthode protected
    organism.bank_accounts.each {|ba| ba.send(:create_accounts)}
    organism.cashes.each {|c| c.send(:create_accounts)}
  end

  # recopie les comptes de l'exercice précédent (s'il y en a un) en modifiant period_id.
  # s'il n'y en a pas, crée un compte pour chaque caisse et bank_account
  def copy_accounts
    if self.previous_period?
      previous_period.accounts.all.each do |a|
        logger.debug  "Recopie du compte #{a.inspect}"
        b = a.dup
        b.period_id = self.id
        b.save!
        logger.debug  "Nouveau compte #{b.inspect}"
      end
    end
  end

  # recopie les natures de l'exercice précédent 's'il y en a un)
  def copy_natures
    pp = self.previous_period
    pp.natures.all.each do |n|
      nn = {name: n.name, comment: n.comment, income_outcome: n.income_outcome} # on commence à construire le hash
      if n.account_id # cas où il y avait un rattachement à un compte
        previous_account=pp.accounts.find(n.account_id) # on identifie le compte de rattachement
        nn[:account_id] = self.accounts.find_by_number(previous_account.number).id # et on recherche son correspondant dans le nouvel exercice
      end
      self.natures.create!(nn) # et on créé maintenant une nature avec les attributs qui restent
    end
  end

  # load natures est appelé lors de la création d'un premier exercice
  # load_natures lit le fichier natures_asso.yml et crée les natures correspondantes
  # retourne le nombre de natures
  def load_natures
    Rails.logger.info 'Création des natures'
    t = load_file_natures("#{Rails.root}/app/assets/parametres/asso/natures.yml")
    t.each do |n|
      a = accounts.find_by_number(n[:acc])
      natures.create(name:n[:name], comment:n[:comment], account:a, income_outcome:n[:income_outcome])
    end
    natures.count
  end

  protected

  def load_file_natures(source)
    YAML::load_file(source)
  rescue
    "Erreur lors du chargement du fichier #{source}"
  end

 
end
