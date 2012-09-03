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
  has_many :lines, :through=>:natures
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
  after_create :copy_accounts, :copy_natures
 

  # TODO voir la gestion des effacer dans les vues et dans le modèle. 

  # TODO mettre dans la migration que start_date et close_date sont obligatoires
 
 # trouve l'exercice précédent en recherchant le premier exercice
 # avec la date de cloture < au start_date de l'exercice actuel
  # renvoie lui même s'il n'y en a pas
  def previous_period
    Period.first(:conditions=>['organism_id = ? AND close_date < ?', self.organism_id, self.start_date],
      :order=>'close_date DESC') || self
  end

  # indique s'il y a un exercice précédent en testant si previous period renvoie un exercice différent de self
  def previous_period?
    (previous_period.id == self.id) ? false : true
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
  
  # renvoie le compte (120) qui sert pour enregistrer le résultat positif de l'exercice
  # ou 129 pour enregistrer le résultat négatif
  def report_account
    accounts.where('number = ?', 12).first
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
    self.errors.add(:close, "Toutes les lignes d'écritures ne sont pas verrouillées") if lines.unlocked.any?
    # il faut un exercice suivant
    self.errors.add(:close, "Pas d'exercice suivant") unless next_period? 
    # il faut un livre d'OD
    self.errors.add(:close, "Il manque un livre d'OD pour passer l'écriture de report") unless organism.books.find_by_type('OdBook')
    # il faut un compte pour le report du résultat
    self.errors.add(:close, "Pas de compte 12 pour le résultat de l'exercice") unless report_account

    self.errors[:close].any? ? false : true

  end


  # indique si l'exercice est clos
  def is_closed?
    open ? false : true
  end

  # Effectue la clôture de l'exercice.
  #
  #  La clôture de l'exercice doit effectuer une écriture de report dans le livre
  #  d'OD à partir du résultat => il faut un compte report à nouveau pour mouvementer
  #  le résultat de l'exercice vers le report.
  # 
  def close
    possible = closable? # closable? ne doit être appelé qu'une fois pour ne pas dupliquer les erreurs (et les requêtes)
    if possible 
      od_book = organism.books.find_by_type('OdBook')
      date = close_date
      Period.transaction do
        # on commence par créer l'écriture de compensation des classes 6 et 7
        accounts.classe_6.each do |acc|
          sold = acc.sold_at(close_date)
          # si le solde est à zero, il ne doit rien écrire (car pas de ligne à 0)
          Line.create!(credit:-sold, debit:0, line_date:date,
            book_id:od_book.id,
            narration:'clôture de l\'exercice', owner_type:'Program') if sold != 0
         end
         
        # les écritures de compensation des classes 6 et 7
        accounts.classe_7.each do |acc|
          sold = acc.sold_at(close_date)
          # si le solde est à zero, il ne doit rien écrire (car pas de ligne à 0)
          Line.create!(debit:-sold, credit:0, line_date:date,
            book_id:od_book.id,
            narration:'clôture de l\'exercice', owner_type:'Program') if sold != 0
         end

#        Line.create!(credit:-sold, debit:0, line_date:close_date,
#            book_id:od_book.id,
#            narration:'clôture de l\'exercice', owner_type:'Program') if sold != 0

        # Il s'agit donc de générer des lignes avec comme intitulé
        self.update_attribute(:open, false) if self.closable?
      end
    end
    return possible
  end

  def recettes_accounts
    accounts.classe_7.all
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

  # recopie les comptes de l'exercice précédent (s'il y en a un)
  def copy_accounts
return unless self.previous_period?
    pp=self.previous_period
    pp.accounts.all.each do |a|
      self.accounts.create! :number=>a.number, title: a.title, used: a.used, accountable_id:a.accountable_id, accountable_type:a.accountable_type
    end
  end

  # recopie les natures de l'exercice précédent 's'il y en a un)
  def copy_natures
    return unless self.previous_period?
    pp=self.previous_period
    pp.natures.all.each do |n|
      nn = {name: n.name, comment: n.comment, income_outcome: n.income_outcome} # on commence à construire le hash
      if n.account_id # cas où il y avait un rattachement à un compte
        previous_account=pp.accounts.find(n.account_id) # on identifie le compte de rattachement
        nn[:account_id] = self.accounts.find_by_number(previous_account.number).id # et on recherche son correspondant dans le nouvel exercice
      end
      self.natures.create!(nn) # et on créé maintenant une nature avec les attributs qui restent
    end
  end


 
end
