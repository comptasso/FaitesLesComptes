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
# le champ first_active_month sert à identifier le premier mois ouvert
# lorsqu'on ferme un mois, tous les journaux correspondants à ce mois sont
# fermés (ce qui valide autmatiquement les écritures qui appartiennent à ces journaux.
# Puis first_active_month est incrémenté.
# TODO mettre ceci dans une transaction


require 'utilities'

class Period < ActiveRecord::Base

  # Les classes ...validator sont des classes spécifiques de validator pour les exercices

  # Valide que le start_date est le lendemain du close date de l'exercice précédent
  class ContiguousValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors[attribute] << "ne peut avoir un trou dans les dates #{record.previous_period.close_date}" if record.previous_period && record.previous_period.close_date != (value - 1.day)
    end
  end

  # Valide que le close_date est bien postérieur au start_date
  class ChronoValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors[attribute] << "la date de cloture doit être postérieure à l'ouverture" if value < record.start_date
    end
  end

 
  belongs_to :organism
  
  has_many :accounts, :dependent=>:destroy
  has_many :journals, :dependent=>:destroy
  has_many :entries, :through=>:journals


  validates :organism_id, :presence=>true
  validates :close_date, :presence=>true,:chrono=>true
  validates :start_date, :presence=>true,:contiguous => true


  # TODO changer le update should not reopen en utilisant un des validate
  before_update :fix_days, :cant_change_start_date, :should_not_reopen
  before_create :should_not_have_more_than_two_open_periods, :fix_days
  before_save :should_not_exceed_24_months, 
    :cant_change_close_date_if_next_period
  after_create  :create_journals

  # TODO voir la gestion des effacer dans les vues et dans le modèle.

  # TODO mettre dans la migration que start_date et close_date sont obligatoires
 
  # Trouve l'exercice précédent
  def previous_period
    Period.first(:conditions=>['organism_id = ? AND close_date < ?', self.organism_id, self.start_date],
      :order=>'close_date DESC')
  end
  # indique s'il y a un exercice précédent
  def previous_period?
    previous_period ? true : false
  end


  # trouve l'exercice suivant
  def next_period
    Period.first(:conditions=>['organism_id = ? AND start_date > ?', self.organism_id, self.close_date],
      :order=>'start_date DESC')
  end

  # indique s'il y a un exercice suivant
  def next_period?
    next_period ? true : false
  end

  # indique si l'exercice est clos
  def is_closed?
    self.open ? false : true
  end

 
 

  def nb_months
    Utilities::nb_mois(self.close_date, self.start_date)+1 # plus un pour tenir compte des bornes
  end

   # renvoie le nombre de jour d'un mois donné de l'exercice
  # mois period est un entier démarrant à 0
  def nb_jour_mois(mois_period)
    self.start_date.months_since(mois_period).end_of_month.day
  end

  # sélectionne le mois par défaut, en l'occurence le mois contenant la date fournie
  # ou le mois le plus proche. Date par défaut est la date du jour
  # TODO faire les tests
  def nearest_month_number(date=nil)
    date ||= Date.today
    # cas où la date est en dehors de la période
    month_number= case
    when date > self.close_date then  self.journals.last(:order=>'jmonth ASC').jmonth
    when date < self.start_date then  self.journals.first(:order=>'jmonth ASC').jmonth
    else # cas où la date est dans la période
      Utilities.nb_mois(self.start_date, date )
    end
    month_number
  end

  # permet d'indiquer l'exercice sous la forme d'une chaine de caractère
  # du type Exercice 2011 si period correspond à une année pleine
  # ou de Mars 2011 à Février 2012 si c'est à cheval sur l'année civile.
  def exercice
    r=''
    if self.start_date==self.start_date.beginning_of_year
      r= 'Exercice ' << self.start_date.year.to_s
    else
      r= '- de ' << (I18n::l self.start_date, :format=>:short_month_year)
      r << ' à ' << (I18n::l self.close_date, :format=>:short_month_year)
    end
    r
  end

  # retourne le nombre d'écritures non validées dans l'exercice
  def nb_unvalidated_entries(month_index)
    nb=0
    self.journals.where(['jmonth=?', month_index]).each do |j|
      nb+=j.nb_unvalidated_entries
    end
    nb
  end

  
  def all_accounts_except_coca
    self.accounts.reject {|a| a.is_child_of_collective_account?}
  end

  alias all_accounts_except_children_of_collective_account all_accounts_except_coca

  def all_active_accounts_except_coca
        self.accounts.reject {|a| a.inactive? || a.is_child_of_collective_account?}
  end

  # general_balance est une méthode qui construit une balance générale
  # en prenant en compte le numéro de compte de départ, de fin
  # la date de début et la date de fin
  #
  # Les valeurs par défaut sont du premier au dernier compte et du début à la fin de l'exercice
  #
  def general_balance(acc_number_from=nil, acc_number_to=nil, date_from=nil, date_to=nil)
    acc_number_from ||= self.accounts.first.acc_number  # remplissage des valeurs par défaut
    acc_number_to ||= self.accounts.last.acc_number
    # TODO ajouter des messages - éventuellement un rescue
    # bizarre comme approche avec le numéro de compte et non l'id
    # TODO ceci est débile car c'est une AREL
#    raise ArgumentError unless self.accounts.where('acc_number= ?', acc_number_from)
#    raise ArgumentError unless self.accounts.where('acc_number= ?', acc_number_to)
    date_from ||= self.start_date
    date_to ||= self.close_date
    GeneralBalance.new(self.id, acc_number_from, acc_number_to, date_from, date_to)
  end

  # auxiliary_balance est une méthode qui construit une balance auxiliaire
  # à partir d'un numéro de compte collectif et d'une date de début et de fin
  #
  # Les valeurs par défaut sont du premier au dernier compte et du début à la fin de l'exercice
  #
  def auxiliary_balance(acc_number_id , date_from=nil, date_to=nil)
    # TODO faire une vérification que les comptes existent bien pour cette période
    # TODO voir s'il ne faudrait pas mieux travailler à partir des id plutôt que des acc_number
    # récupération des dates
    date_from ||= self.start_date
    date_to ||= self.close_date
    AuxiliaryBalance.new(acc_number_id , date_from, date_to)
  end

  # Check_balance prend l'ensemble des comptes de period et vérifie que le
  # total debit est égal au total_credit
  #
  # is_balanced? est utilisée dans les opérations de cloture mais sera plus tard
  # utilisé à chaque modification de period.
  # TODO faire un is_balanced lors de l'appel d'une nouvelle période
  #
  def is_balanced?
    gb=self.general_balance
    a=gb.total_soldes_cumule
    return false unless a.first == a.last
    return true
  end

  # report_entries écrit dans l'exercice suivant l'écriture d'ouverture de
  # l'exercice - report de tous les comptes de bilan et solde dans le compte de
  # report à nouveau.
  #
  def report_entries
    # on prend tous les comptes commençant par 1 à 5
    begin
      as=[]
      5.times do |i|  # TODO il doit y avoir plus élégant
        search=i.to_s+'%'
        as << self.accounts.order(:acc_number).where('acc_number LIKE ?', search).all
        as.flatten!
      end
      # préparation des éléments pour créer l'écriture

      np=self.next_period
     
      
      odj=np.journals.where('abbreviation=? AND jmonth= ?', 'OD', 0).first
      date=np.start_date
      e=Entry.new(:entry_date=>date, :journal_id=>odj.id,
        :narration=>"Ouverture de l'exercice")
      # l'entry existe, on créé les lignes
      as.each do |a| #a pour account
        if a.solde.abs  > 0 # pour chaque compte dont le solde est à zero
        # il faut que le compte existe 
        npa=np.accounts.find_by_acc_number(a.acc_number)
        if npa.nil? # ou le créer
          npa=np.accounts.create!(:acc_number=>a.acc_number,:name=>a.name, :comment=>a.comment, :regroupement=>a.regroupement)
        end
          e.lines.build(:account_id=>npa.id, :amount=>a.solde.abs , :dc=> a.solde > 0 ? true : false )
        end
      end # on a fait tous les reports
      
      # il reste à faire l'écriture du report proprement dit (autrement dit d'équilibrer l'écriture
      report= e.total_debit - e.total_credit # on calcule le solde
      if report != 0
      report_account = np.accounts.where('acc_number=?', '12').first
      e.lines.build(:account_id=>report_account.id, :amount=>report , :dc=> true )
      end
      e.save
     return e.lines.size
    rescue
      return 0
    end

  end

  # TODO pourra être éliminée dans un environnement de production
  # TODO à mettre dans une tache RAKE
  # fonction permettant de générer un nombre spécifique d'écriture aléatoires
  # dans les 120 premiers jours de l'exercice - utile pour la mise au point
  

  # ferme le mois actif,
  # ferme les journaux correspondants à ce mois,
  # passe le mois actif au mois suivant s'il existe
  def close_month
    raise ArgumentError if self.first_active_month >= self.nb_months
    self.journals.where('jmonth=?', self.first_active_month).each {|j| j.close}
    self.first_active_month +=1
    self.save
  end

  # permet de créer des comptes à partir d'un fichier source au format YAML
  # retourne le nombre de compte créé.
  def create_accounts(source)
    raise ArgumentError unless self.id
    nb_accounts_created=0
    if source=='previous'
      self.previous_period.accounts.each { |a| nb_accounts_created +=1 if a.copy(self.id) }
    else
      YAML::load_file(source).each  {|a| nb_accounts_created +=1 if  self.accounts.build(a) }
      self.save
    end
    # TODO reprendre ce point quand les fichiers YAML seront finalisés.
    nb_accounts_created
  end



  # Les conditions pour qu'un exercice puisse être fermé sont :
  # qu'il soit ouvert
  # que tous ses journaux soit fermés
  # que l'exercice précédent soit fermé
  def is_lockable?
    self.errors.add(:lock, 'Exercice déja fermé') unless self.open
    # tous les journaux doivent être fermés
    self.errors.add(:lock, 'Tous les journaux ne sont pas fermés; ') if self.journals.where('open=?', true).any?
    # l'exercice précédent, s'il existe, doit être ferme
  self.errors.add(:lock, "L'exercice précédent n'est pas fermé; ") if self.previous_period && self.previous_period.open
   # il faut un exercice suivant
   np=self.next_period
   self.errors.add(:lock, "Pas d'exercice suivant; ") if np.nil?
   return false if self.errors[:lock].any?
   # il faut un compte pour le report du résultat
   self.errors.add(:lock, "Pas de compte de report à nouveau") if np.accounts.where('acc_number=?', '12').first.nil?
   # il faut un journal d'OD
   jod=np.journals.where('jmonth=?',0).where('abbreviation=?', 'OD').first
   self.errors.add(:lock, "Pas de journal d'OD dans l'exercice suivant; ") if jod.nil?
   return false if self.errors[:lock].any?
   # qui doit être ouvert
   # TODO il faut interdire de fermer un mois si l'exercice précédent n'est pas clos
   self.errors.add(:lock, "Le journal d'OD de l'exercice suivant est fermé; ") unless jod.open
   self.errors[:lock].any? ? false : true

  end

  

  protected

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
    if self.organism.nb_open_periods >= 2
      self.errors.add(:base, "Impossible d'avoir plus de deux exercices ouverts")
      return false
    end
     
  end

  def should_not_exceed_24_months
    if self.close_date-self.start_date > 731
      self.errors.add(:close_date, 'un exercice ne peut avoir plus de deux ans')
      return false
    end
  end

  def fix_days
    self.start_date=self.start_date.beginning_of_month
    self.close_date=self.close_date.end_of_month
  end


  # méthode appelée après la création d'une période et créant les différents
  # journaux mensuels sur la base de la liste des journaux qui sont attachés
  # à la organism et des mois qui sont dans months
  # Il faudrait mettre ceci dans une transaction pour éviter d'avoir un état
  # non matirisé dans la table.
  def create_journals
    #Si la liste est vide on retourne
    return if self.organism.journal_lists.empty?
    
    # pour chaque journal
    self.organism.journal_lists.each do |jl|
      month=0
      date=self.start_date
      # on parcourt les différents mois de la période et pour chaque mois on crée
      # les journaux associés
      while date < self.close_date
        self.journals.build(:abbreviation=>jl.abbreviation, :name=>jl.title,
          :comment=>jl.comment, :jmonth=>month) 
        date= date.months_since(1)
        month +=1
      end
    end
    self.save #  on sauve la période et donc tous les journaux associés
  end
end
